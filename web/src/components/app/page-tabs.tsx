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
        <ion-tab tabTitle="HOME" tabIcon="home" name="tab-home">
          <ion-nav />
        </ion-tab>
        <ion-tab tabTitle="PROPERTIES" tabIcon="planet" name="tab-properties">
          <ion-nav />
        </ion-tab>
        <ion-tab tabTitle="TENANTS" tabIcon="people" name="tab-tenants">
          <ion-nav />
        </ion-tab>
        <ion-tab tabTitle="LEASES" tabIcon="paper" name="tab-leases">
          <ion-nav />
        </ion-tab>
      </ion-tabs>
    ]
  }
}
