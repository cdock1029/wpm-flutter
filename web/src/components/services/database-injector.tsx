import { Component, Method, Prop } from '@stencil/core'
import { IFirebaseInjector } from './firebase-injector'

import { FirebaseNamespace } from '@firebase/app-types'
import { FirebaseDatabase } from '@firebase/database-types'

export interface IDatabaseInjector {
  create(): Promise<FirebaseDatabase>
}

@Component({ tag: 'database-injector' })
export class DatabaseInjector implements IDatabaseInjector {
  @Prop({ connect: 'firebase-injector' })
  fbInjector: IFirebaseInjector

  fb: FirebaseNamespace

  async componentWillLoad() {
    this.fb = await this.fbInjector.create()
  }

  @Method()
  create(): Promise<FirebaseDatabase> {
    return Promise.resolve(this.fb.database())
  }
}
