import '@ionic/core'
import '@stencil/core'

import { Component, Prop } from '@stencil/core'
import { IAuthInjector } from '../services/auth-injector'
import { NavControllerBase } from '@ionic/core'

@Component({
  tag: 'logout-button'
})
export class LogoutButton {
  @Prop({ connect: 'auth-injector' })
  authInjector: IAuthInjector

  @Prop({ connect: 'ion-nav' })
  nav: NavControllerBase

  logOutHandler = async () => {
    console.log('logouthandler click')
    const auth = await this.authInjector.create()
    const navCtrl: NavControllerBase = await (this
      .nav as any).componentOnReady()

    await auth.signOut()

    navCtrl.setRoot('app-login')
  }

  render() {
    return [
      <ion-button onClick={this.logOutHandler}>
        <ion-icon slot="icon-only" name="log-out" />
      </ion-button>
    ]
  }
}
