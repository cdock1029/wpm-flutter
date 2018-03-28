import { Component } from '@stencil/core'

@Component({
  tag: 'app-home',
  styleUrl: 'app-home.scss'
})
export class AppHome {
  render() {
    return (
      <ion-page>
        <ion-header>
          <common-toolbar title="WPM" />
        </ion-header>
        <ion-content>
          <p>Have setup actions here.</p>
          <ul>
            <li>create company</li>
            <li>link / instructions to create properties</li>
            <li>link / instructions to .. create units/tenants/leases??</li>

            <li>
              link / instructions to manage individual user account, contact
              info, profile, username password settings, etc.
            </li>
          </ul>
        </ion-content>
      </ion-page>
    )
  }
}
