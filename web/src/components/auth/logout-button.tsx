import { Component, Prop } from '@stencil/core'
import { NavControllerBase } from '@ionic/core'
import { FirebaseNamespace } from '@firebase/app-types'

declare var firebase: FirebaseNamespace

@Component({
  tag: 'logout-button'
})
export class LogoutButton {
  @Prop({ connect: 'ion-nav' })
  nav: NavControllerBase

  logOutHandler = async () => {
    console.log('logouthandler click')
    const auth = firebase.auth()
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
