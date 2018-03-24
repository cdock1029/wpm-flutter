import { Component, Prop } from '@stencil/core'
import { IAuthInjector } from '../services/auth-injector'
import { PopoverController, NavControllerBase } from '@ionic/core'

@Component({
  tag: 'more-popover-button'
})
export class MorePopoverButton {
  @Prop({ connect: 'ion-popover-controller' })
  popoverCtrl: PopoverController

  @Prop({ connect: 'auth-injector' })
  authInjector: IAuthInjector

  @Prop({ connect: 'ion-nav' })
  nav: NavControllerBase

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
      const auth = await this.authInjector.create()
      const navCtrl: NavControllerBase = await (this
        .nav as any).componentOnReady()

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
