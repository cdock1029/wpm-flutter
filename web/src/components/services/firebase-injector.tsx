import { Component, Method } from '@stencil/core'
import { firebase } from '@firebase/app'
import '@firebase/database'
import '@firebase/auth'

import { FirebaseNamespace } from '@firebase/app-types'

const config = {
  apiKey: 'AIzaSyBVQa5KM6YoqwyTE2O8nESPi_hS676S0RM',
  authDomain: 'don-dob.firebaseapp.com',
  databaseURL: 'https://don-dob.firebaseio.com',
  projectId: 'don-dob',
  storageBucket: 'don-dob.appspot.com',
  messagingSenderId: '178447522597'
}

export interface IFirebaseInjector {
  create(): Promise<FirebaseNamespace>
}

@Component({ tag: 'firebase-injector' })
export class FirebaseInjector implements IFirebaseInjector {
  initFirebase() {
    if (!firebase.apps.length) {
      console.log('initializeApp')
      firebase.initializeApp(config)
    } else {
      console.log('already initialized, ', firebase)
    }
  }
  componentWillLoad() {
    this.initFirebase()
  }

  @Method()
  create(): Promise<FirebaseNamespace> {
    return Promise.resolve(firebase)
  }
}
