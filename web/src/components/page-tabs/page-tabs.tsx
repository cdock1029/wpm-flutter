import '@ionic/core'
import '@stencil/core'

import { Component } from '@stencil/core'

@Component({
  tag: 'page-tabs',
  styleUrl: 'page-tabs.css'
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
      <ion-tabs>
        <ion-tab title="Home" icon="home" component="app-home" />
        <ion-tab title="Properties" icon="planet" component="properties-page" />
        <ion-tab title="Tenants" icon="people" component="tenants-page" />
      </ion-tabs>
    ]
  }
}
