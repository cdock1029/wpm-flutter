import '@ionic/core'
import '@stencil/core'

import { Component, Event, EventEmitter, Listen } from '@stencil/core'

@Component({
  tag: 'properties-page'
})
export class PropertiesPage {
  @Event() logOut: EventEmitter

  logOutHandler() {
    console.log('onLogOut - emmitting "logOut event.."')
    this.logOut.emit('something')
  }

  @Listen('logOut')
  onLogOut(event) {
    console.log('heard logOut within class. event=', event)
  }

  render() {
    return [
      <ion-page>
        <ion-header>
          <ion-toolbar>
            <ion-buttons slot="start">
              <ion-menu-button />
            </ion-buttons>
            <ion-title>Properties</ion-title>
            <ion-buttons slot="end">
              <logout-button />
            </ion-buttons>
          </ion-toolbar>
        </ion-header>
        <ion-content>
          <div>propertie page</div>
        </ion-content>
      </ion-page>
    ]
  }
}
