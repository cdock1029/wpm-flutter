import { Component, Prop } from '@stencil/core'
import { IDatabaseInjector } from '../services/database-injector'
import { PopoverController } from '@ionic/core'

@Component({
  tag: 'property-popover-button'
})
export class PropertyPopoverButton {
  @Prop({ connect: 'database-injector' })
  dbInjector: IDatabaseInjector

  @Prop({ connect: 'ion-popover-controller' })
  popoverCtrl: PopoverController

  private popover: HTMLIonPopoverElement

  presentPopover = async e => {
    this.popover = await this.popoverCtrl.create({
      component: 'property-popover',
      ev: e
    })
    this.popover.present()
    const { data } = await this.popover.onDidDismiss()
    console.log('dismissed DATA=', data)
  }

  render() {
    return (
      <ion-button onClick={this.presentPopover}>
        <ion-icon slot="icon-only" name="more" />
      </ion-button>
    )
  }
}
