import '@ionic/core'
import '@stencil/core'

import { Component } from '@stencil/core'

@Component({
  tag: 'tenants-page'
})
export class TenantsPage {
  render() {
    return [
      <ion-header>
        <ion-toolbar>
          <ion-buttons slot="start">
            <ion-menu-button />
          </ion-buttons>
          <ion-title>Tenants</ion-title>
          {/* <ion-buttons slot="end">
            <ion-button onClick={() => {}}>
              <ion-icon slot="icon-only" name="more" />
            </ion-button>
          </ion-buttons> */}
        </ion-toolbar>
      </ion-header>,
      <ion-content>
        <div>tenants page</div>
      </ion-content>
    ]
  }
}
