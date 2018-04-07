import { Component, Prop } from '@stencil/core'
import { PopoverController, Nav } from '@ionic/core'
import { FirebaseNamespace } from '@firebase/app-types'

declare var firebase: FirebaseNamespace

@Component({
  tag: 'more-popover-button'
})
export class MorePopoverButton {
  @Prop({ connect: 'ion-popover-controller' })
  popoverCtrl: PopoverController

  @Prop({ connect: 'ion-nav' })
  nav

  private popover: HTMLIonPopoverElement

  presentPopover = async e => {
    this.popover = await this.popoverCtrl.create({
      component: 'more-popover',
      ev: e
    })
    this.popover.present()
    const { data } = await this.popover.onDidDismiss()
    console.log('dismissed DATA=', data)

    if (data) {
      const auth = firebase.auth()
      const navCtrl: Nav = await (this.nav as any).componentOnReady()

      await auth.signOut()

      navCtrl.setRoot('app-login')
    }
  }

  render() {
    return (
      <ion-button onClick={this.presentPopover}>
        <ion-icon slot="icon-only" name="more" />
      </ion-button>
    )
  }
}
