import '@ionic/core'
import '@stencil/core'

import { Component } from '@stencil/core'

@Component({
  tag: 'tenants-page'
})
export class TenantsPage {
  render() {
    return (
      <ion-page>
        <ion-header>
          <ion-toolbar>
            <ion-buttons slot="start">
              <ion-menu-button />
            </ion-buttons>
            <ion-title>Tenants</ion-title>
            <ion-buttons slot="end">
              <logout-button />
            </ion-buttons>
          </ion-toolbar>
        </ion-header>
        <ion-content>
          <ion-list>
            <ion-list-header>Tenants</ion-list-header>
          </ion-list>
        </ion-content>
      </ion-page>
    )
  }
}
