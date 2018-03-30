import { Component, Method } from '@stencil/core'

import { FirebaseFirestore, DocumentReference } from '@firebase/firestore-types'
import { FirebaseAuth, User } from '@firebase/auth-types'

declare var firebase: any
const collator = new Intl.Collator(undefined, {
  numeric: true,
  sensitivity: 'base'
})

// function stringy(object: {}): string {
//   return JSON.stringify(object, null, 2)
// }

export interface IDatabase {
  // properties(options: { once: boolean; (data: any): any }): Promise<Property[]>
  properties(cb: (props: Property[]) => void): Promise<() => void>
  units(propertyId: string, cb: (units: Unit[]) => void): Promise<() => void>
  tenants(cb: (tens: Tenant[]) => void): Promise<() => void>
  addProperty(data: Property): Promise<DocumentReference>
  addUnit(unit: Unit, propertyId: string): Promise<DocumentReference>
  addTenant(data: Tenant): Promise<DocumentReference>
  property(id: string): Promise<Property>
  unit(ids: { propertyId: string; unitId: string }): Promise<Unit>
  leasesForUnit(
    unitId: string,
    cb: (leases: Lease[]) => void
  ): Promise<() => void>

  onUserStateChanged(cb: (user: User) => void): () => void
  getUser(): User

  signIn(email: string, password: string): Promise<void>
  signOut(): Promise<void>
  // activeProperty(cb: (activeProp: Property) => void): Promise<() => void>
}

class Database implements IDatabase {
  private fs: FirebaseFirestore = firebase.firestore()
  private auth: FirebaseAuth = firebase.auth()

  private getActiveCompany = async (): Promise<DocumentReference> => {
    const uid = this.auth.currentUser.uid
    const userDataSnap = await this.fs
      .collection('users')
      .doc(uid)
      .get()
    const userData = userDataSnap.data()
    const companyRef: DocumentReference = userData.activeCompany.ref
    return companyRef
  }

  signIn(email, password) {
    return this.auth.signInWithEmailAndPassword(email, password)
  }
  signOut() {
    return this.auth.signOut()
  }

  properties = async (cb): Promise<() => void> => {
    const cid = (await this.getActiveCompany()).id
    const ref = await this.fs
      .collection('companies')
      .doc(cid)
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
    const cid = (await this.getActiveCompany()).id
    const ref = await this.fs
      .doc(`companies/${cid}/properties/${propertyId}`)
      .collection('units')

    return ref.onSnapshot(snapshot => {
      const units: Unit[] = snapshot.docs
        .map(doc => {
          const data = doc.data()
          return { id: doc.id, address: data.address }
        })
        .sort((a: { address: string }, b: { address: string }) => {
          return collator.compare(a.address, b.address)
        })
      cb(units)
    })
  }

  leasesForUnit = async (unitId: string, cb): Promise<() => void> => {
    const companyRef = await this.getActiveCompany()
    const query = companyRef
      .collection('leases')
      .where(`units.${unitId}`, '==', true)

    return query.onSnapshot(snap => {
      const leases: Lease[] = snap.docs.map(doc => {
        const l = doc.data()
        return { id: doc.id, rent: l.rent, units: l.units, balance: l.balance }
      })
      cb(leases)
    })
  }

  property = async (pid: string): Promise<Property> => {
    console.log('get property w/ id=', pid)
    const cid = (await this.getActiveCompany()).id
    const snap = await this.fs.doc(`companies/${cid}/properties/${pid}`).get()
    const data = snap.data()
    return { id: snap.id, name: data['name'] }
  }

  onUserStateChanged = (cb: (user: User) => void): (() => void) => {
    const authUnsub = this.auth.onAuthStateChanged((user: User) => {
      cb(user)
    })
    return authUnsub
  }
  getUser = () => this.auth.currentUser

  async unit({ unitId, propertyId }): Promise<Unit> {
    const cid = (await this.getActiveCompany()).id
    const snap = await this.fs
      .doc(`companies/${cid}/properties/${propertyId}/units/${unitId}`)
      .get()
    const data = snap.data()
    return { id: snap.id, address: data.address }
  }

  addProperty = async (data: Property): Promise<DocumentReference> => {
    const cid = (await this.getActiveCompany()).id
    const ref = this.fs
      .collection('companies')
      .doc(cid)
      .collection('properties')
      .doc()

    await ref.set({ name: data.name.trim() })
    return ref
  }
  addUnit = async (
    unit: Unit,
    propertyId: string
  ): Promise<DocumentReference> => {
    // console.log(`addUnit propertyId=${propertyId}, unit=`, unit)
    const comp = await this.getActiveCompany()
    const ref = comp
      .collection('properties')
      .doc(propertyId)
      .collection('units')
      .doc()
    await ref.set({ address: unit.address.toUpperCase().trim() })
    return ref
  }
  addTenant = async (data: Tenant): Promise<DocumentReference> => {
    const cid = (await this.getActiveCompany()).id
    const ref = this.fs
      .doc(`companies/${cid}`)
      .collection('tenants')
      .doc()

    const { firstName, lastName } = data
    await ref.set({ firstName: firstName.trim(), lastName: lastName.trim() })
    return ref
  }

  tenants = async (cb): Promise<() => void> => {
    const cid = (await this.getActiveCompany()).id
    const ref = await this.fs
      .collection('companies')
      .doc(cid)
      .collection('tenants')
      .orderBy('lastName')

    return ref.onSnapshot(snapshot => {
      const tens: Tenant[] = snapshot.docs.map(doc => {
        const data = doc.data()
        return {
          id: doc.id,
          firstName: data.firstName,
          lastName: data.lastName
        }
      })
      cb(tens)
    })
  }
}

export interface IDatabaseInjector {
  create(): Promise<IDatabase>
}

@Component({ tag: 'database-injector' })
export class DatabaseInjector implements IDatabaseInjector {
  private static db = new Database()

  @Method()
  create(): Promise<IDatabase> {
    return Promise.resolve(DatabaseInjector.db)
  }
}

interface Model {
  id?: string
}

export interface Company extends Model {
  name: string
}

export interface Property extends Model {
  name: string
}

export interface Unit extends Model {
  address: string
}

export interface Tenant extends Model {
  firstName: string
  lastName: string
}
export interface User extends User {}

export interface Lease extends Model {
  rent: number
  balance: number
  units: { [unitId: string]: boolean }
}

// export interface AppUser extends Model {
//   authData: User
//   userData: UserData
// }

export interface UserData {
  activeCompany: Company
  // activeProperty: Property
}
