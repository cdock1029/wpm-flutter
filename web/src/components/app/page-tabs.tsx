import { Component } from '@stencil/core'

@Component({
  tag: 'page-tabs'
})
export class PageTabs {
  componentWillLoad() {
    console.log('page tabs componentWillLoad')
  }
  componentDidLoad() {
    console.log('page tabs componentDidLoad')
  }
  render() {
    console.log('page tabs render')
    return [
      <ion-tabs color="primary" tabbarPlacement="bottom" tabbarHighlight>
        <ion-tab label="HOME" icon="home" name="tab-home">
          <ion-nav />
        </ion-tab>
        <ion-tab label="PROPERTIES" icon="planet" name="tab-properties">
          <ion-nav />
        </ion-tab>
        <ion-tab label="TENANTS" icon="people" name="tab-tenants">
          <ion-nav />
        </ion-tab>
        <ion-tab label="LEASES" icon="paper" name="tab-leases">
          <ion-nav />
        </ion-tab>
      </ion-tabs>
    ]
  }
}
