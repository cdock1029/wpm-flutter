import { Component } from '@stencil/core'

@Component({
  tag: 'property-tabs'
})
export class PageTabs {
  render() {
    return [
      <ion-tabs color="primary" tabbarPlacement="bottom" tabbarHighlight>
        <ion-tab label="Leases" icon="planet" name="tab-property-leases">
          <ion-nav />
        </ion-tab>
        <ion-tab label="Units" icon="home" name="tab-property-units">
          <ion-nav />
        </ion-tab>
        <ion-tab label="Tenants" icon="people" name="tab-property-tenants">
          <ion-nav />
        </ion-tab>
      </ion-tabs>
    ]
  }
}
