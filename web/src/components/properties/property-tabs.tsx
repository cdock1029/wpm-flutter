import { Component } from '@stencil/core'

@Component({
  tag: 'property-tabs'
})
export class PageTabs {
  render() {
    return [
      <ion-tabs color="primary" tabbarPlacement="bottom" tabbarHighlight>
        <ion-tab tabTitle="Leases" tabIcon="planet" name="tab-property-leases">
          <ion-nav />
        </ion-tab>
        <ion-tab tabTitle="Units" tabIcon="home" name="tab-property-units">
          <ion-nav />
        </ion-tab>
        <ion-tab
          tabTitle="Tenants"
          tabIcon="people"
          name="tab-property-tenants"
        >
          <ion-nav />
        </ion-tab>
      </ion-tabs>
    ]
  }
}
