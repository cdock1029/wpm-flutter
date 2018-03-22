import '@ionic/core'
import '@stencil/core'

import { Component } from '@stencil/core'

@Component({
  tag: 'loading-spinner',
  styleUrl: 'loading-spinner.scss'
})
export class LoadingSpinner {
  render() {
    return (
      <ion-page>
        <ion-header>
          <ion-toolbar color="primary">
            <ion-title>WPM Property Manager</ion-title>
          </ion-toolbar>
        </ion-header>
        <ion-content>
          <div class="spinner-container">
            <ion-spinner name="bubbles" />
          </div>
        </ion-content>
      </ion-page>
    )
  }
}
