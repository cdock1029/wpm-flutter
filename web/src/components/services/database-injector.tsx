import { Component, Method, Prop } from '@stencil/core'
import { IFirebaseInjector } from './firebase-injector'

import { FirebaseFirestore, DocumentReference } from '@firebase/firestore-types'
import { FirebaseAuth } from '@firebase/auth-types'
import { IAuthInjector } from './auth-injector'

export interface IDatabase {
  // properties(options: { once: boolean; (data: any): any }): Promise<Property[]>
  properties(cb: (props: Property[]) => void): Promise<() => void>
  units(propertyId: string, cb: (units: Unit[]) => void): Promise<() => void>
  addProperty(data: Property): Promise<DocumentReference>
  property(id: string): Promise<Property>
  unit(ids: { propertyId: string; unitId: string }): Promise<Unit>
}

class Database implements IDatabase {
  private fs: FirebaseFirestore
  private auth: FirebaseAuth

  constructor() {
    console.log('Database constructor time=', new Date().toLocaleTimeString())
  }

  setFirestore(fs: FirebaseFirestore) {
    this.fs = fs
  }
  setAuth(auth: FirebaseAuth) {
    this.auth = auth
  }

  private getActiveCompany = async (): Promise<string> => {
    const uid = this.auth.currentUser.uid
    const snap = await this.fs
      .collection('users')
      .doc(uid)
      .get()
    const data = snap.data()
    return data['activeCompany']
  }

  // properties = async ({ once = false, cb = null }): Promise<Property[]> => {
  //   const companyId = await this.getActiveCompany()
  //   const ref = await this.fs
  //     .collection('companies')
  //     .doc(companyId)
  //     .collection('properties')

  //   if (once) {
  //     const snap = await ref.get()
  //     return snap.docs.map(doc => {
  //       const data = doc.data()
  //       return { id: doc.id, name: data['name'] }
  //     })
  //   }
  //   ref.onSnapshot(snapshot => {
  //     snapshot.docs.map(doc => {
  //       const data = doc.data()
  //       return {id: doc.id, name: data['name']}
  //     })
  //   })
  // }

  properties = async (cb): Promise<() => void> => {
    const companyId = await this.getActiveCompany()
    const ref = await this.fs
      .collection('companies')
      .doc(companyId)
      .collection('properties')
      .orderBy('name')

    return ref.onSnapshot(snapshot => {
      const props: Property[] = snapshot.docs.map(doc => {
        const data = doc.data()
        return { id: doc.id, name: data['name'] }
      })
      cb(props)
    })
  }
  units = async (propertyId: string, cb): Promise<() => void> => {
    const cid = await this.getActiveCompany()
    const ref = await this.fs
      .doc(`companies/${cid}/properties/${propertyId}`)
      .collection('units')

    return ref.onSnapshot(snapshot => {
      const units: Unit[] = snapshot.docs.map(doc => {
        const data = doc.data()
        return { id: doc.id, address: data.address }
      })
      cb(units)
    })
  }

  property = async (pid: string): Promise<Property> => {
    const cid = await this.getActiveCompany()
    const snap = await this.fs.doc(`companies/${cid}/properties/${pid}`).get()
    const data = snap.data()
    return { id: snap.id, name: data['name'] }
  }

  async unit({ unitId, propertyId }): Promise<Unit> {
    const cid = await this.getActiveCompany()
    const snap = await this.fs
      .doc(`companies/${cid}/properties/${propertyId}/units/${unitId}`)
      .get()
    const data = snap.data()
    return { id: snap.id, address: data.address }
  }

  addProperty = async (data: Property): Promise<DocumentReference> => {
    const cid = await this.getActiveCompany()
    const ref = this.fs
      .collection('companies')
      .doc(cid)
      .collection('properties')
      .doc()

    await ref.set(data)
    return ref
  }
}

export interface IDatabaseInjector {
  create(): Promise<IDatabase>
}

@Component({ tag: 'database-injector' })
export class DatabaseInjector implements IDatabaseInjector {
  @Prop({ connect: 'firebase-injector' })
  fbInjector: IFirebaseInjector

  @Prop({ connect: 'auth-injector' })
  authInjector: IAuthInjector

  private static db = new Database()

  async componentWillLoad() {
    const [auth, fsI] = await Promise.all([
      this.authInjector.create(),
      this.fbInjector.create()
    ])

    DatabaseInjector.db.setFirestore(fsI.firestore())
    DatabaseInjector.db.setAuth(auth)
  }

  @Method()
  create(): Promise<IDatabase> {
    return Promise.resolve(DatabaseInjector.db)
  }
}

interface Model {
  id?: string
}

export interface Property extends Model {
  name: string
}

export interface Unit extends Model {
  address: string
}
