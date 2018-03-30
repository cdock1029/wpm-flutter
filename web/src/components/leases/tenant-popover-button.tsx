import { Component, Prop } from '@stencil/core'
import { PopoverController } from '@ionic/core'

@Component({
  tag: 'tenant-popover-button',
  styleUrl: 'tenant-popover-button.scss'
})
export class TenantPopoverButton {
  @Prop({ connect: 'ion-popover-controller' })
  popCtrl: PopoverController

  @Prop() names: string[]

  private popover

  async componentWillLoad() {}

  presentPopover = async e => {
    console.log('popover button names=', this.names)
    this.popover = await this.popCtrl.create({
      component: 'tenant-popover',
      componentProps: { names: this.names },
      ev: e
    })
    this.popover.present()
  }
  render() {
    const names = this.names
    return (
      <ion-item>
        {names[0]}
        {names.length > 1 && (
          <ion-button
            fill="clear"
            item-end
            icon-only
            onClick={this.presentPopover}
            padding-left
            color="dark"
          >
            <ion-icon slot="icon-only" name="arrow-dropdown" />
          </ion-button>
        )}
      </ion-item>
    )
  }
}
