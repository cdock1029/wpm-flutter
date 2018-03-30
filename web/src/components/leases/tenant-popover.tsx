import { Component, Prop } from '@stencil/core'

@Component({
  tag: 'tenant-popover'
})
export class TenantPopover {
  @Prop() names: string[]

  async componentWillLoad() {
    console.log('tenant popover data=', this.names)
  }

  render() {
    return (
      <ion-list>{this.names.map(name => <ion-item>{name}</ion-item>)}</ion-list>
    )
  }
}
