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
const validator_1 = require("./validator");
admin.initializeApp(functions.config().firebase);
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
    const { unitId, propertyId } = event.params;
    const unitRef = event.data.ref;
    const unit = event.data.data();
    unit.objectID = unitId;
    // unitId -> units -> propertyId
    const parentRef = event.data.ref.parent.parent;
    // update unitCount in transaction
    yield admin.firestore().runTransaction((transaction) => __awaiter(this, void 0, void 0, function* () {
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
//# sourceMappingURL=index.js.map