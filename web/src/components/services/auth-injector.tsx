import { Component, Method, Prop } from '@stencil/core'
import { IFirebaseInjector } from './firebase-injector'

import { FirebaseNamespace } from '@firebase/app-types'
import { FirebaseAuth } from '@firebase/auth-types'

export interface IAuthInjector {
  create(): Promise<FirebaseAuth>
}

@Component({ tag: 'auth-injector' })
export class AuthInjector implements IAuthInjector {
  @Prop({ connect: 'firebase-injector' })
  fbInjector: IFirebaseInjector

  fb: FirebaseNamespace

  async componentWillLoad() {
    this.fb = await this.fbInjector.create()
  }

  @Method()
  create(): Promise<FirebaseAuth> {
    return Promise.resolve(this.fb.auth())
  }
}
