import { Component, Prop } from '@stencil/core'

@Component({
  tag: 'common-toolbar'
})
export class CommonToolbar {
  @Prop() title: string

  render() {
    return [
      <ion-toolbar color="primary">
        <ion-buttons slot="start">
          <ion-menu-button />
        </ion-buttons>
        <ion-title>{this.title}</ion-title>
        <ion-buttons slot="end">
          <more-popover-button />
        </ion-buttons>
      </ion-toolbar>,
      <ion-toolbar color="primary">
        <ion-searchbar />
      </ion-toolbar>
    ]
  }
}
