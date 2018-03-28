import { Component, Method } from '@stencil/core'

import { FirebaseFirestore, DocumentReference } from '@firebase/firestore-types'
import { FirebaseAuth, User } from '@firebase/auth-types'

function stringy(object: {}): string {
  return JSON.stringify(object, null, 2)
}

export interface IDatabase {
  // properties(options: { once: boolean; (data: any): any }): Promise<Property[]>
  properties(cb: (props: Property[]) => void): Promise<() => void>
  units(propertyId: string, cb: (units: Unit[]) => void): Promise<() => void>
  tenants(cb: (tens: Tenant[]) => void): Promise<() => void>
  addProperty(data: Property): Promise<DocumentReference>
  addTenant(data: Tenant): Promise<DocumentReference>
  property(id: string): Promise<Property>
  unit(ids: { propertyId: string; unitId: string }): Promise<Unit>

  onUserStateChanged(cb: (user: AppUser) => void): () => void
  getAppUser(): AppUser

  signIn(email: string, password: string): Promise<void>
  signOut(): Promise<void>
  // activeProperty(cb: (activeProp: Property) => void): Promise<() => void>
}

declare var firebase: any

let appUser: AppUser = { authData: null, userData: null }

firebase.auth().onAuthStateChanged(fbUser => {
  if (fbUser === null) {
    appUser = { authData: null, userData: null }
  }
})

class Database implements IDatabase {
  private fs: FirebaseFirestore = firebase.firestore()
  private auth: FirebaseAuth = firebase.auth()

  private getActiveCompany = async (): Promise<Company> => {
    if (appUser.userData != null) {
      return appUser.userData.activeCompany
    }
    const snap = await this.fs
      .collection('users')
      .doc(appUser.authData.uid)
      .get()
    const userData = snap.data()
    return userData['activeCompany']
  }

  private subscribeUserData = (
    user: User,
    cb: (userData: any) => void
  ): (() => void) => {
    const uid = user.uid
    const unsub = this.fs
      .collection('users')
      .doc(uid)
      .onSnapshot(userDataSnap => {
        const userData = userDataSnap.data()
        cb(userData)
      })
    return unsub
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
      const units: Unit[] = snapshot.docs.map(doc => {
        const data = doc.data()
        return { id: doc.id, address: data.address }
      })
      cb(units)
    })
  }

  property = async (pid: string): Promise<Property> => {
    const cid = (await this.getActiveCompany()).id
    const snap = await this.fs.doc(`companies/${cid}/properties/${pid}`).get()
    const data = snap.data()
    return { id: snap.id, name: data['name'] }
  }

  onUserStateChanged = (cb: (user: AppUser) => void): (() => void) => {
    let userDataUnsub = () => {}
    const authUnsub = this.auth.onAuthStateChanged(authData => {
      console.log(
        `inner onAuthStateChanged callback appUser=${stringy(appUser)}`
      )
      console.log(
        `inner onAuthStateChanged callback authData=${Boolean(authData)}`
      )
      appUser = { ...appUser, authData }
      cb(appUser)
      if (authData !== null) {
        userDataUnsub = this.subscribeUserData(authData, (userData: any) => {
          console.log(
            `inner subscribeUserData callback appUser=${stringy(appUser)}`
          )
          console.log(
            `inner subscribeUserData callback userData=${stringy(userData)}`
          )
          appUser = { ...appUser, userData }
          cb(appUser)
        })
      }
    })
    return () => {
      authUnsub()
      userDataUnsub()
    }
  }
  getAppUser = () => appUser

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

export interface AppUser extends Model {
  authData: User
  userData: UserData
}

export interface UserData {
  activeCompany: Company
  activeProperty: Property
}
