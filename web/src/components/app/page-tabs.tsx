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
      <ion-tabs color="primary">
        <ion-tab title="Home" icon="home" name="tab-home">
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
