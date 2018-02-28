import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';
import * as algoliasearch from 'algoliasearch';
import * as parse from 'csv-parse';
import * as path from 'path';
import * as CloudStorage from '@google-cloud/storage';
import { DocumentReference, DocumentSnapshot, DocumentData, CollectionReference, WriteBatch, WriteResult, FieldValue, Query } from '@google-cloud/firestore';
import * as transform from 'stream-transform';

// import {ReadS} from '@types/google-cloud__storage';
import { Validator } from './validator';
import { Parser } from 'csv-parse/lib';

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

interface Algolia extends DocumentData {
  objectID: string;
}
interface Tenant extends Algolia {
  firstName: string;
  lastName: string;
  phone: string;
  email: string;
}
interface Unit extends Algolia {
  address: string;
  ordering?: number | Number;
  propertyName?: string;
}
interface Property extends Algolia {
  name: string;
  unitCount?: number;
}

interface TenantParams {
  tenantId: string;
}
interface PropertyParams {
  propertyId: string;
}
interface UnitParams extends PropertyParams {
  unitId: string;
}

// TODO: think about how we can use this async operation to lookup tenant names, etc.. combine it all here ?
// keeping things in sync complicated... but easier to have fewer entities..
// what are the queries? unit / tenant name mostly..
// maybe balance..
// or payment value..
// or even date of some data-entry..
export const onUnitCreate = functions.firestore.document('properties/{propertyId}/units/{unitId}').onCreate(async (event) => {
  // TODO: we only should need to scope this for a `Company`.. when data model is changed to multi-user..
  const index = client.initIndex(ALGOLIA_INDEX_UNITS);
  const { unitId } = event.params as UnitParams;

  const unitRef: DocumentReference = event.data.ref;
  const unit: Unit = event.data.data();
  unit.objectID = unitId;

  // unitId -> units -> propertyId
  const parentRef: DocumentReference = event.data.ref.parent.parent;

  // update unitCount in transaction
  await db.runTransaction(async (transaction: FirebaseFirestore.Transaction) => {
    const parentData: DocumentSnapshot = await transaction.get(parentRef)
    const parentProperty: Property = parentData.data() as Property;
    if (typeof parentProperty !== 'undefined' && parentProperty !== null) {
      unit.propertyName = parentProperty.name;
    }

    const unitCount: number = parentProperty.unitCount || 0;

    unit.ordering = unitCount;

    transaction.update(parentRef, {
      unitCount: unitCount + 1,
    })
  });

  // to save the 'ordering' property
  const fbUpdate = unitRef.update(unit)
  const algoliaUpdate = index.saveObject(unit);

  return Promise.all([fbUpdate, algoliaUpdate]);
});

export const onUnitDelete = functions.firestore.document('properties/{propertyId}/units/{unitId}').onDelete(async event => {
  const index = client.initIndex(ALGOLIA_INDEX_UNITS);
  const { unitId } = event.params as UnitParams;

  // unitId -> units -> propertyId
  const parentRef: DocumentReference = event.data.ref.parent.parent;

  // update unitCount in transaction
  await db.runTransaction(async (transaction: FirebaseFirestore.Transaction) => {
    const parentData: DocumentSnapshot = await transaction.get(parentRef)
    const parentProperty: Property = parentData.data() as Property;

    const unitCount = parentProperty.unitCount;

    return transaction.update(parentRef, {
      unitCount: (unitCount || 1) - 1,
    })
  });

  return index.deleteObject(unitId);
});

export const onTenantCreate = functions.firestore.document('tenants/{tenantId}').onCreate((event) => {
  const index = client.initIndex(ALGOLIA_INDEX_TENANTS);
  const { tenantId: objectID } = event.params as TenantParams;

  const tenant: Tenant = event.data.data();
  tenant.objectID = objectID;
  return index.saveObject(tenant);
});

export const onTenantDelete = functions.firestore.document('tenants/{tenantId}').onDelete((event) => {
  const { tenantId: objectID } = event.params as TenantParams;
  const index = client.initIndex(ALGOLIA_INDEX_TENANTS);
  return index.deleteObject(objectID);
});

// TODO: this path will be prefixed by "company/{companyId}/.."
// then index will also be dynamically prefixed..
export const onTenantUpdate = functions.firestore.document('tenants/{tenantId}').onUpdate((event) => {
  const index = client.initIndex(ALGOLIA_INDEX_TENANTS);
  const { tenantId: objectID } = event.params as TenantParams;

  const oldTenant: Tenant = event.data.previous.data();
  const updatedTenant: Tenant = event.data.data();

  console.log('onTenantUpdate - oldTenant:', oldTenant);
  console.log('onTenantUpdate - updatedTenant:', updatedTenant);

  return index.saveObject(updatedTenant);
});

export const validateEmail = functions.https.onRequest((req, res) => {
  const email = req.query.email || 'invalid';
  const isEmail = Validator.isEmail(email);
  res.json({ isEmail });
});


// function handleStream(record, callback) {
//   setTimeout(function () {
//     callback(null, record.join(' ') + '\n');
//   }, 500);
// }

export const processCsv = functions.storage.object().onChange(event => {
  const object = event.data;

  const fileBucket = object.bucket; // The Storage bucket that contains the file.
  const filePath = object.name as string; // File path in the bucket.
  const contentType = object.contentType; // File content type.
  const resourceState = object.resourceState; // The resourceState is 'exists' or 'not_exists' (for file/folder deletions).
  const metageneration = object.metageneration as number;
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

  const parser: Parser = parse({ columns: true, auto_parse: true });

  const baseName: string = path.basename(filePath, '.csv');

  const streamPromise = new Promise((resolve, reject) => {
    const output: any[] = [];
    parser.on('readable', () => {
      let record: any = parser.read();
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
          } else {
            normalized[key.toLowerCase()] = val;
          }
        });

        batch.set(tenantDoc, normalized);
      })

      resolve(batch.commit());
    });
    parser.on('error', error => reject(error));
  })

  readStream.pipe(parser);//.pipe(transformer).pipe(process.stdout);

  return streamPromise;
});

async function processCompanyFieldFix(tenantsRef: CollectionReference, batch: WriteBatch, offset: number = 0): Promise<WriteResult[]> {
  let query = tenantsRef.orderBy('tenant').limit(50);
  if (offset) {
    console.log('start after offset:', offset);
    query = query.offset(offset * 50);
  }

  const results = await query.get();

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
          batch.update(docSnap.ref, { company: admin.firestore.FieldValue.delete() })
        } else {
          batch.update(docSnap.ref, { company: admin.firestore.FieldValue.delete(), unit: companyVal })
        }
      }
    });
    // const lastDoc = results.docs[results.docs.length - 1];

    return processCompanyFieldFix(tenantsRef, batch, offset + 1);
  }
  return batch.commit();
}

export const fixQbo = functions.firestore.document('qbo/{propertyId}').onUpdate(async event => {
  // if (typeof event.params === 'undefined') {
  //   throw new Error('param propertyId not included. Bug..');
  // }
  // const propertyId: string = event.params.propertyId;

  const fixField = event.data.get('fix_company_field');

  if (fixField !== null && fixField === true) {
    const docRef: DocumentReference = event.data.ref;

    const tenantsRef = docRef.collection('tenants');
    try {
      const result: WriteResult[] = await processCompanyFieldFix(tenantsRef, db.batch());
      if (result !== null) {
        console.log('writeResult length:', result.entries.length);
      }
      return result;
    } catch (error) {
      console.error('Error getting write result from processCompanyFieldFix func:', error.message);
      return null;
    }
  }
  console.log('no fixField');
  return null;
});

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