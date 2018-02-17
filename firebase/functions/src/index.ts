import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';
import * as algoliasearch from 'algoliasearch';
import { Validator } from './validator';

// tslint:disable-next-line:no-implicit-dependencies
import { DocumentReference, DocumentSnapshot, DocumentData } from '@google-cloud/firestore';

admin.initializeApp(functions.config().firebase);

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
  ordering: number;
  propertyName?: string;
}
interface Property extends Algolia {
  name: string;
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
  const { unitId, propertyId } = event.params as UnitParams;

  const unit: Unit = event.data.data();
  unit.objectID = unitId;

  // lookup property name? sheesh...
  const propertySnapshot: DocumentSnapshot = await admin.firestore().doc(`properties/${propertyId}`).get();

  const docData = propertySnapshot.data();

  if (typeof docData !== 'undefined' && docData !== null) {
    const property = docData as Property;
    unit.propertyName = property.name;
  }
  return index.saveObject(unit);
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