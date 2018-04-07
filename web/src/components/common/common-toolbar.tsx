import { Component, Prop } from '@stencil/core'

@Component({
  tag: 'common-toolbar'
})
export class CommonToolbar {
  @Prop() pageTitle: string

  render() {
    return [
      <ion-toolbar color="primary">
        <ion-buttons slot="start">
          <ion-menu-button autoHide={true} menu="left" />
        </ion-buttons>
        <ion-title>{this.pageTitle}</ion-title>
      </ion-toolbar>,
      <ion-toolbar color="primary">
        <ion-searchbar />
      </ion-toolbar>
    ]
  }
}
