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

enum trxnType {
  CHARGE = 'CHARGE',
  PAYMENT = 'PAYMENT',
  CREDIT = 'CREDIT'
}
enum trxnSubType {
  RENT = 'RENT',
  LATE_FEE = 'LATE_FEE',
  NSF_FEE = 'NSF_FEE',
}

interface Transaction {
  date: Date;
  amount: number;
  type: trxnType;
  subType?: trxnSubType;
  prevTrxn?: string;
  nextTrxn?: string;
  localBalance: number;
}
interface TrxnParams {
  companyId: string;
  leaseId: string;
  transactionId: string;
}

function updatedBalance(currBalance: number = 0, trxnAmount: number, type: trxnType): number {
  switch (type) {
    case trxnType.CHARGE:
      return currBalance + trxnAmount;
    case trxnType.PAYMENT:
    case trxnType.CREDIT:
      return currBalance - trxnAmount;
  }
  throw new TypeError(`Error calculating balance. Unhandled transaction type=[${type}]`);
}

function shouldUpdateBalance(updated: Transaction, previous: Transaction): boolean {
  return updated.amount !== previous.amount || updated.type !== previous.type;
}

export const onTransactionWrite = functions.firestore.document('companies/{companyId}/leases/{leaseId}/transactions/{transactionId}').onWrite(async event => {
  const params = event.params as TrxnParams;
  const transactionsCollectionRef: CollectionReference = event.data.ref.parent;
  const leaseRef = transactionsCollectionRef.parent

  console.log('handling transaction write params=', params);

  if (!event.data.previous.exists) {
    // creation
    console.log('trxn creation');
    const trxn: Transaction = event.data.data();

    return db.runTransaction(async dbTrxn => {
      if (leaseRef) {
        const leaseData = (await leaseRef.get()).data();
        if (leaseData) {
          const bal = leaseData.balance;
          const newBal = updatedBalance(bal, trxn.amount, trxn.type);
          return dbTrxn.update(leaseRef, { balance: newBal });
        } else return 'leaseData null';
      } else return 'leaseRef null';
    });
  }
  const previous: Transaction = event.data.previous.data();

  if (event.data.exists) {
    // updating
    const updated: Transaction = event.data.data();

    if (shouldUpdateBalance(updated, previous)) {
      console.log('trxn updating');

      return db.runTransaction(async dbTrxn => {
        if (leaseRef) {
          const leaseData = (await leaseRef.get()).data();
          if (leaseData) {
            const bal = leaseData.balance;
            // reverse the old trxn..
            const undoOld = updatedBalance(bal, previous.amount * -1, previous.type);
            // apply the new..
            const newBal = updatedBalance(undoOld, updated.amount, updated.type);
            return dbTrxn.update(leaseRef, { balance: newBal });
          } else return 'leaseData null';
        } else return 'leaseRef null';
      });
    }
    return null;
  }
  // deleting
  console.log('trxn deletion');

  return db.runTransaction(async dbTrxn => {
    if (leaseRef) {
      const leaseData = (await leaseRef.get()).data();
      if (leaseData) {
        const bal = leaseData.balance || 0;
        // reverse the old trxn value..
        const newBal = updatedBalance(bal, previous.amount * -1, previous.type);
        return dbTrxn.update(leaseRef, { balance: newBal });
      } else return 'leaseData null';
    } else return 'leaseRef null';
  });
  // throw new Error(`Unacounted for state. leaseId=[${params.leaseId}], transactionId=[${params.transactionId}]`);
});

/*
export const onTransactionCreate = functions.firestore.document('companies/{companyId}/leases/{leaseId}/transactions/{transactionId}').onCreate(async event => {
  const params = event.params as TrxnParams;
  const transactionsCollectionRef: CollectionReference = event.data.ref.parent;

  const leaseRef = transactionsCollectionRef.parent as DocumentReference;

  // when created.. only have date and amount. Need to...
  // - update global Balance
  // - show/track effect on balance for each trxn
  // - update pointers between trxns

  const trxn: Transaction = event.data.data();
  const trxnRef: DocumentReference = event.data.ref;
  const trxnDate: Date = trxn.date;

  // only 2 things that would effect balance
  db.runTransaction(async dbTrxn => {
    if (leaseRef) {
      const leaseData = (await leaseRef.get()).data();
      if (leaseData) {
        const bal = leaseData.balance;
        const newBal = updatedBalance(bal, trxn.amount, trxn.type);
        dbTrxn.update(leaseRef, { balance: newBal });
      }
    }
  }


  // desc because we want the 'most recent' transaction to the left of this new one
  const prevQuery = transactionsCollectionRef.where('date', '<', trxnDate).orderBy('date', 'desc').limit(1);

  // asc beause we want the 'earliest'/'closest' trxn to right of this new one
  const nextQuery = transactionsCollectionRef.where('date', '>', trxnDate).orderBy('date', 'asc').limit(1);

  const queries = Promise.all([
    prevQuery.get(),
    nextQuery.get(),
  ]);

  const results = await queries;
  const prevDocs = results[0].docs;
  const nextDocs = results[1].docs;


  // base case: this is first trxn, none exist before or after
  if (!prevDocs.length && !nextDocs.length) {
    // update global Balance and document balance
    console.log('handling first trxn created');
    db.runTransaction(async dbTrxn => {
      // update local balance
      dbTrxn.update(trxnRef, { localBalance: trxn.amount });
    });
  } else if (!prevDocs.length && nextDocs.length) {
    db.runTransaction(async dbTrxn => {

      // nothing before, but trxns after (inserted at beginning)
      const next = nextDocs[0];
      const nextData = next.data() as Transaction;

      // making this first trxn, so no previous balance
      const localBalance = updatedBalance(0, trxn.amount, trxn.type);

      // update 2 pointers
      dbTrxn.update(next.ref, { prevTrxn: params.transactionId });
      dbTrxn.update(trxnRef, { nextTrxn: next.id, localBalance });
      // TODO how to handle this in onUpdate...***
    });

  } else if (!nextDocs.length) {
    // previous docs exist, but not nextDoc. "this" is the newest..
    console.log('appending latest trxn');
    db.runTransaction(async dbTrxn => {
      // get the previous trxn
      // update next pointer to point to "this" new trxn id
      const prev = prevDocs[0];
      // update local balances
      console.log(`prev Trxn data=[${JSON.stringify(prev.data())}]`);
      const prevData = prev.data() as Transaction;

      const prevBalance = prevData.localBalance;
      const localBalance = updatedBalance(prevBalance, trxn.amount, trxn.type);

      dbTrxn.update(prev.ref, { nextTrxn: params.transactionId });
      dbTrxn.update(trxnRef, { prevTrxn: prev.id, localBalance });
    });
  } else {
    // prev and next exist..
    // ** update pointers both directions **
    console.log('inserting trxn between others');
    db.runTransaction(async dbTrxn => {
      const prev = prevDocs[0];
      const next = nextDocs[0];

      dbTrxn.update(prev.ref, { nextTrxn: params.transactionId });
      dbTrxn.update(next.ref, { prevTrxn: params.transactionId });

      // get lease
      // const lease = await leaseRef.get();
      // const data = lease.data() as DocumentData;
      // const currBalance: number = data.balance;

      // update local balances
      const prevData = prev.data() as Transaction;
      const prevBalance = prevData.localBalance;
      const localBalance = updatedBalance(prevBalance, trxn.amount, trxn.type);
      dbTrxn.update(trxnRef, { localBalance });
    });
  }

});

// 1. "dependencies" have changed, either:
// - 'previous transaction' ptr on left
// - trxn Amount
// - trxn type
function haveDependenciesChanged(trans: Transaction, transOldData: Transaction, transPrevLeftId: string | undefined): boolean {
  if (transPrevLeftId !== transOldData.prevTrxn && trans.localBalance === transOldData.localBalance) return true;
  if (trans.amount !== transOldData.amount) return true;
  if (trans.type !== transOldData.type) return true;

  return false;
}

// TODO.. started down the wrong path above. trxnId's only exist on updates.
export const onTransactionUpdate = functions.firestore.document('companies/{companyId}/leases/{leaseId}/transactions/{transactionId}').onUpdate(async event => {
  // 1. is prevTrxn pointer updated but not my balance ?
  // then a trxn was added to my left "before me".. my dependencies changed
  // 2. or if trxn amount was changed.
  // --> recalculate my balance

  // is my balance updated ?
  // do i have a 'next pointer' ?
  // 1. yes --> then recalculate "nextTrxn" balance
  // 2. no --> I'm the "last transaction", update global balance.

  const params = event.params as TrxnParams;
  const transactionsCollectionRef: CollectionReference = event.data.ref.parent;
  const leaseRef = transactionsCollectionRef.parent;

  const trxn: Transaction = event.data.data();
  const oldTrxnData: Transaction = event.data.previous.data();

  const trxnRef: DocumentReference = event.data.ref;

  // only 2 things that would effect balance
  if (trxn.type !== oldTrxnData.type || trxn.amount !== oldTrxnData.amount) {
    db.runTransaction(async dbTrxn => {
      if (leaseRef) {
        const leaseData = (await leaseRef.get()).data();
        if (leaseData) {
          const bal = leaseData.balance;
          const newBal = updatedBalance(bal, trxn.amount, trxn.type);
          dbTrxn.update(leaseRef, { balance: newBal });
        }
      }
    });
  }




  // TODO: this should handle case where 'previous trxn' was deleted also
  if (haveDependenciesChanged(trxn, oldTrxnData, trxn.prevTrxn)) {
    // need to recalculate my 'local balance'
    db.runTransaction(async dbTrxn => {

      // check 'left ptr' to get starting point for calc.
      let localBalanceInput: number = 0;
      if (trxn.prevTrxn) {
        const data = (await transactionsCollectionRef.doc(trxn.prevTrxn).get()).data();
        localBalanceInput = (data && (data as Transaction).localBalance) || 0;
      }
      const localBalance = updatedBalance(localBalanceInput, trxn.amount, trxn.type);
      dbTrxn.update(trxnRef, { localBalance });
      return Promise.resolve('local balance recalculated');
    });
  } else if (trxn.localBalance !== oldTrxnData.localBalance) {
    // 2. This happens after above block... local balance has changed --> cascade to my "right/next" trxn
    if (trxn.nextTrxn) {

      // update my next pntr's balance
      db.runTransaction(async dbTrxn => {
        const nextPtrDoc = await transactionsCollectionRef.doc(trxn.nextTrxn).get();
        const nextPtrTrxn = nextPtrDoc.data() as Transaction;

        // input value is 'this' trxn.localBalance that was just updated
        const localBalance = updatedBalance(trxn.localBalance, nextPtrTrxn.amount, nextPtrTrxn.type);
        dbTrxn.update(nextPtrDoc.ref, { localBalance });
        return Promise.resolve('after trxn balance updated, it updated nextPtr balance');
      });

    } else {

      // OR, if I'm "last", update Global lease Balance
      // TODO : should we specify 'when' this should run or just fall through to it ?
      db.runTransaction(async dbTrxn => {
        if (leaseRef) {
          dbTrxn.update(leaseRef, { balance: trxn.localBalance });
          return Promise.resolve('updated global balance from last trxn localBalance');
        } else {
          const { companyId, leaseId } = params;
          throw new Error(`leaseRef was null while updating global Balance. companyId=[${companyId}], leaseId=[${leaseId}]`);
        }
      });
    }
  }

});
*/
