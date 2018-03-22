import { Component, Method } from '@stencil/core'
import { firebase } from '@firebase/app'
import '@firebase/firestore'
import '@firebase/auth'

import { FirebaseNamespace } from '@firebase/app-types'

const config = {
  apiKey: 'AIzaSyDlWm0Ftq30kFD4LnPJ5sf9Mz8vyrcjIfM',
  authDomain: 'wpmfirebaseproject.firebaseapp.com',
  databaseURL: 'https://wpmfirebaseproject.firebaseio.com',
  projectId: 'wpmfirebaseproject',
  storageBucket: 'wpmfirebaseproject.appspot.com',
  messagingSenderId: '1038799458160'
}

export interface IFirebaseInjector {
  create(): Promise<FirebaseNamespace>
}

@Component({ tag: 'firebase-injector' })
export class FirebaseInjector implements IFirebaseInjector {
  initFirebase() {
    if (!firebase.apps.length) {
      // console.log('initializeApp')
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
