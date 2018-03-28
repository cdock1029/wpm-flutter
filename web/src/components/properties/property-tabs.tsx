import { Component } from '@stencil/core'

@Component({
  tag: 'property-tabs'
})
export class PageTabs {
  render() {
    return [
      <ion-tabs>
        <ion-tab title="Units" icon="home" name="tab-units">
          <ion-nav />
        </ion-tab>
        <ion-tab title="Properties" icon="planet" name="tab-properties">
          <ion-nav />
        </ion-tab>
        <ion-tab title="Tenants" icon="people" name="tab-tenants">
          <ion-nav />
        </ion-tab>
      </ion-tabs>
    ]
  }
}
