import '@ionic/core'
import '@stencil/core'

import { Component } from '@stencil/core'

@Component({
  tag: 'property-tabs'
})
export class PageTabs {
  render() {
    return [
      <ion-tabs>
        <ion-tab title="Units" icon="home" component="app-home" />
        <ion-tab title="Properties" icon="planet" name="tab-properties">
          <ion-nav />
        </ion-tab>
        <ion-tab title="Tenants" icon="people" component="tenants-page" />
      </ion-tabs>
    ]
  }
}
