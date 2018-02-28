"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const admin = require("firebase-admin");
const functions = require("firebase-functions");
const algoliasearch = require("algoliasearch");
const parse = require("csv-parse");
const path = require("path");
const CloudStorage = require("@google-cloud/storage");
// import {ReadS} from '@types/google-cloud__storage';
const validator_1 = require("./validator");
admin.initializeApp(functions.config().firebase);
const gcs = CloudStorage();
const db = admin.firestore();
const ALGOLIA_ID = functions.config().algolia.app_id;
const ALGOLIA_ADMIN_KEY = functions.config().algolia.admin_key;
const ALGOLIA_SEARCH_KEY = functions.config().algolia.search_key;
const ALGOLIA_INDEX_TENANTS = 'tenants';
// const ALGOLIA_INDEX_PROPERTIES = 'properties';
const ALGOLIA_INDEX_UNITS = 'units';
// const ALGOLIA_INDEX_ = 'tenants';
const client = algoliasearch(ALGOLIA_ID, ALGOLIA_ADMIN_KEY);
// TODO: think about how we can use this async operation to lookup tenant names, etc.. combine it all here ?
// keeping things in sync complicated... but easier to have fewer entities..
// what are the queries? unit / tenant name mostly..
// maybe balance..
// or payment value..
// or even date of some data-entry..
exports.onUnitCreate = functions.firestore.document('properties/{propertyId}/units/{unitId}').onCreate((event) => __awaiter(this, void 0, void 0, function* () {
    // TODO: we only should need to scope this for a `Company`.. when data model is changed to multi-user..
    const index = client.initIndex(ALGOLIA_INDEX_UNITS);
    const { unitId } = event.params;
    const unitRef = event.data.ref;
    const unit = event.data.data();
    unit.objectID = unitId;
    // unitId -> units -> propertyId
    const parentRef = event.data.ref.parent.parent;
    // update unitCount in transaction
    yield db.runTransaction((transaction) => __awaiter(this, void 0, void 0, function* () {
        const parentData = yield transaction.get(parentRef);
        const parentProperty = parentData.data();
        if (typeof parentProperty !== 'undefined' && parentProperty !== null) {
            unit.propertyName = parentProperty.name;
        }
        const unitCount = parentProperty.unitCount || 0;
        unit.ordering = unitCount;
        transaction.update(parentRef, {
            unitCount: unitCount + 1,
        });
    }));
    // to save the 'ordering' property
    const fbUpdate = unitRef.update(unit);
    const algoliaUpdate = index.saveObject(unit);
    return Promise.all([fbUpdate, algoliaUpdate]);
}));
exports.onUnitDelete = functions.firestore.document('properties/{propertyId}/units/{unitId}').onDelete((event) => __awaiter(this, void 0, void 0, function* () {
    const index = client.initIndex(ALGOLIA_INDEX_UNITS);
    const { unitId } = event.params;
    // unitId -> units -> propertyId
    const parentRef = event.data.ref.parent.parent;
    // update unitCount in transaction
    yield db.runTransaction((transaction) => __awaiter(this, void 0, void 0, function* () {
        const parentData = yield transaction.get(parentRef);
        const parentProperty = parentData.data();
        const unitCount = parentProperty.unitCount;
        return transaction.update(parentRef, {
            unitCount: (unitCount || 1) - 1,
        });
    }));
    return index.deleteObject(unitId);
}));
exports.onTenantCreate = functions.firestore.document('tenants/{tenantId}').onCreate((event) => {
    const index = client.initIndex(ALGOLIA_INDEX_TENANTS);
    const { tenantId: objectID } = event.params;
    const tenant = event.data.data();
    tenant.objectID = objectID;
    return index.saveObject(tenant);
});
exports.onTenantDelete = functions.firestore.document('tenants/{tenantId}').onDelete((event) => {
    const { tenantId: objectID } = event.params;
    const index = client.initIndex(ALGOLIA_INDEX_TENANTS);
    return index.deleteObject(objectID);
});
// TODO: this path will be prefixed by "company/{companyId}/.."
// then index will also be dynamically prefixed..
exports.onTenantUpdate = functions.firestore.document('tenants/{tenantId}').onUpdate((event) => {
    const index = client.initIndex(ALGOLIA_INDEX_TENANTS);
    const { tenantId: objectID } = event.params;
    const oldTenant = event.data.previous.data();
    const updatedTenant = event.data.data();
    console.log('onTenantUpdate - oldTenant:', oldTenant);
    console.log('onTenantUpdate - updatedTenant:', updatedTenant);
    return index.saveObject(updatedTenant);
});
exports.validateEmail = functions.https.onRequest((req, res) => {
    const email = req.query.email || 'invalid';
    const isEmail = validator_1.Validator.isEmail(email);
    res.json({ isEmail });
});
// function handleStream(record, callback) {
//   setTimeout(function () {
//     callback(null, record.join(' ') + '\n');
//   }, 500);
// }
exports.processCsv = functions.storage.object().onChange(event => {
    const object = event.data;
    const fileBucket = object.bucket; // The Storage bucket that contains the file.
    const filePath = object.name; // File path in the bucket.
    const contentType = object.contentType; // File content type.
    const resourceState = object.resourceState; // The resourceState is 'exists' or 'not_exists' (for file/folder deletions).
    const metageneration = object.metageneration;
    if (typeof contentType === 'undefined' || !contentType.startsWith('text/csv')) {
        console.log('object is not a csv');
        return null;
    }
    if (resourceState === 'not_exists') {
        console.log('This is a deletion event.');
        return null;
    }
    if (resourceState === 'exists' && metageneration > 1) {
        console.log('This is a metadata change event.');
        return null;
    }
    console.log('file path:', filePath);
    const bucket = gcs.bucket(fileBucket);
    const readStream = bucket.file(filePath).createReadStream();
    // const transformer = transform(handleStream, { parallel: 10 });
    const parser = parse({ columns: true, auto_parse: true });
    const baseName = path.basename(filePath, '.csv');
    const streamPromise = new Promise((resolve, reject) => {
        const output = [];
        parser.on('readable', () => {
            let record = parser.read();
            while (record) {
                output.push(record);
                record = parser.read();
            }
        });
        parser.on('finish', () => {
            // console.log('parser finished. output=', output);
            const batch = db.batch();
            // 'columbiana-manor.csv'
            const companyDoc = db.collection('qbo').doc();
            batch.set(companyDoc, { name: baseName });
            const companyTenantCollection = companyDoc.collection('tenants');
            output.forEach(data => {
                // delete data[''];
                // delete data['Address'];
                // delete data['Attachments'];
                // if (!data['Email']) {
                //   delete data['EMAIL'];
                // }
                // if (!data['NOTES']) {
                //   delete data['NOTES'];
                // }
                // if (!data['PHONE']) {
                //   delete data['PHONE'];
                // }
                const tenantDoc = companyTenantCollection.doc();
                const normalized = {};
                Object.keys(data).forEach(key => {
                    const val = data[key];
                    if (typeof val === 'string') {
                        if (val !== '') {
                            normalized[key.toLowerCase()] = val.toUpperCase();
                        }
                    }
                    else {
                        normalized[key.toLowerCase()] = val;
                    }
                });
                batch.set(tenantDoc, normalized);
            });
            resolve(batch.commit());
        });
        parser.on('error', error => reject(error));
    });
    readStream.pipe(parser); //.pipe(transformer).pipe(process.stdout);
    return streamPromise;
});
function processCompanyFieldFix(tenantsRef, batch, offset = 0) {
    return __awaiter(this, void 0, void 0, function* () {
        let query = tenantsRef.orderBy('tenant').limit(50);
        if (offset) {
            console.log('start after offset:', offset);
            query = query.offset(offset * 50);
        }
        const results = yield query.get();
        if (results.docs.length > 0) {
            console.log('results.docs.length:', results.docs.length);
            results.forEach(docSnap => {
                const data = docSnap.data();
                // console.log('docSnap data', data);
                const companyVal = data['company'];
                if (typeof companyVal !== 'undefined') {
                    // console.log('pre-batch-update. companyVal:', companyVal);
                    if (companyVal === null || typeof companyVal === 'object') {
                        //fix null
                        batch.update(docSnap.ref, { company: admin.firestore.FieldValue.delete() });
                    }
                    else {
                        batch.update(docSnap.ref, { company: admin.firestore.FieldValue.delete(), unit: companyVal });
                    }
                }
            });
            // const lastDoc = results.docs[results.docs.length - 1];
            return processCompanyFieldFix(tenantsRef, batch, offset + 1);
        }
        return batch.commit();
    });
}
exports.fixQbo = functions.firestore.document('qbo/{propertyId}').onUpdate((event) => __awaiter(this, void 0, void 0, function* () {
    // if (typeof event.params === 'undefined') {
    //   throw new Error('param propertyId not included. Bug..');
    // }
    // const propertyId: string = event.params.propertyId;
    const fixField = event.data.get('fix_company_field');
    if (fixField !== null && fixField === true) {
        const docRef = event.data.ref;
        const tenantsRef = docRef.collection('tenants');
        try {
            const result = yield processCompanyFieldFix(tenantsRef, db.batch());
            if (result !== null) {
                console.log('writeResult length:', result.entries.length);
            }
            return result;
        }
        catch (error) {
            console.error('Error getting write result from processCompanyFieldFix func:', error.message);
            return null;
        }
    }
    console.log('no fixField');
    return null;
}));
// export const onUnitOrderUpdate = functions.firestore.document('properties/{propertyId}/units/{unitId}').onUpdate(async event => {
//   const params = event.params;
//   if (typeof params === 'undefined') {
//     return null;
//   }
//   const newOrdering = event.data['ordering'];
//   const prevOrdering = event.data.previous['ordering'];
//   if (newOrdering === prevOrdering) {
//     return;
//   }
//   const { propertyId, unitId } = params;
//   // get the 2 items with same ordering..
//   const orderedItemsQuery: Query = db.collection(`properties/${propertyId}/units`).where('ordering', '==', newOrdering);
//   const result = await orderedItemsQuery.get();
//   if (result.docs.length < 2) {
//     console.log('units with ordering result < 2');
//     return null;
//   }
//   const oldSnapArr = result.docs.filter(snap => snap.id !== unitId);
//   if (oldSnapArr.length) {
//     const oldDocSnap = oldSnapArr[0];
//     return oldDocSnap.ref.update({ ordering: prevOrdering });
//   }
//   return null;
// });
//# sourceMappingURL=index.js.map