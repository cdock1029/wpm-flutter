import { Component } from '@stencil/core'

@Component({
  tag: 'app-home',
  styleUrl: 'app-home.scss'
})
export class AppHome {
  render() {
    return (
      <ion-page>
        <ion-header>
          <ion-toolbar color="primary">
            <ion-buttons slot="start">
              <ion-menu-button />
            </ion-buttons>
            <ion-title>WPM</ion-title>
            <ion-buttons slot="end">
              <logout-button />
            </ion-buttons>
          </ion-toolbar>
        </ion-header>
        <ion-content>
          <p>Manage properties & tenant accounts</p>
        </ion-content>
      </ion-page>
    )
  }
}
