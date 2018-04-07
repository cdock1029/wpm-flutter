import '@ionic/core'
import '@stencil/core'

import { Component, Prop, Listen, State } from '@stencil/core'
import { ToastController, LoadingController } from '@ionic/core'
import {
  User,
  IDatabaseInjector,
  IDatabase
} from '../services/database-injector'

@Component({
  tag: 'my-app',
  styleUrl: 'my-app.scss'
})
export class MyApp {
  @Prop({ connect: 'ion-toast-controller' })
  toastCtrl: ToastController

  @Prop({ connect: 'ion-loading-controller' })
  loadCtrl: LoadingController

  @Prop({ connect: 'database-injector' })
  dbInjector: IDatabaseInjector

  @State()
  auth: {
    user: User
    loaded: boolean
  } = { user: null, loaded: false }

  private db: IDatabase
  private unsub: () => void

  private loadingEl: HTMLIonLoadingElement

  authStateChanged = (user: User) => {
    console.log('my-app authStateChange User =>', user)
    this.loadingEl.dismiss()
    this.auth = {
      user,
      loaded: true
    }
  }

  async componentWillLoad() {
    console.log('my-app componentWillLoad')
    const loaderProm = this.loadCtrl.create({
      content: 'Loading..',
      spinner: 'lines'
    })
    const dbProm = this.dbInjector.create()
    const [_loadingEl, _db] = await Promise.all([loaderProm, dbProm])
    // console.log(_loadingEl)
    this.loadingEl = _loadingEl
    this.db = _db
    await this.loadingEl.present()
  }

  componentDidLoad() {
    console.log('my-app componentDidLoad user => ', Boolean(this.auth.user))
    this.unsub = this.db.onUserStateChanged(this.authStateChanged)
    this.setupToastController()
  }

  componentDidUnload() {
    if (this.unsub) {
      console.log('unsubbing')
      this.unsub()
    }
  }

  renderRouter = () => {
    return (
      <ion-router useHash={false}>
        <ion-route url="/login" component="app-login" />
        <ion-route-redirect from="*" to={!this.auth.user ? '/login' : null} />

        <ion-route component="page-tabs">
          <ion-route url="/" component="tab-home">
            <ion-route component="app-home" />
          </ion-route>
          <ion-route url="/properties" component="tab-properties">
            <ion-route component="properties-page" />
            <ion-route url="/:propertyId" component="property-detail" />
            <ion-route
              url="/:propertyId/units/:unitId"
              component="unit-detail"
            />
          </ion-route>

          <ion-route url="/tenants" component="tab-tenants">
            <ion-route component="tenants-page" />
          </ion-route>
          <ion-route url="/leases" component="tab-leases">
            <ion-route component="lease-table" />
          </ion-route>
        </ion-route>

        {/* <ion-route url="/property" component="property-tabs">
          <ion-route url="/:propertyId" component="tab-property-units">
            <ion-route component="property-detail" />
          </ion-route>
          <ion-route url="/tenants" component="tab-property-tenants">
            <ion-route component="tenants-page" />
          </ion-route>
          <ion-route url="/leases" component="tab-property-leases">
            <ion-route component="app-home" />
          </ion-route>
        </ion-route> */}

        {/* <ion-route url="/properties" component="properties-page" />
        <ion-route url="/properties/:propertyId" component="property-detail" />
        <ion-route
          url="/properties/:propertyId/units/:unitId"
          component="unit-detail"
        /> */}
      </ion-router>
    )
  }

  render() {
    const { user, loaded } = this.auth
    console.log(
      `render my-app => loaded=[${loaded}], user=[${Boolean(user)}]]?`
    )
    return !loaded ? null : (
      <ion-app>
        {this.renderRouter()}
        <ion-split-pane>
          {user && (
            <ion-menu side="left">
              <ion-header>
                <ion-toolbar color="primary">
                  <ion-title>WPM</ion-title>
                  <ion-buttons slot="right">
                    <more-popover-button />
                  </ion-buttons>
                </ion-toolbar>
              </ion-header>
              <ion-content>
                <nav-menu user={user} />
              </ion-content>
            </ion-menu>
          )}
          {/* <ion-router-outlet main /> */}
          <ion-nav swipeBackEnabled={false} main />
        </ion-split-pane>
      </ion-app>
    )
  }

  @Listen('body:ionToastWillDismiss')
  reload() {
    window.location.reload()
  }

  setupToastController = () => {
    /*
      Handle service worker updates correctly.
      This code will show a toast letting the
      user of the PWA know that there is a
      new version available. When they click the
      reload button it then reloads the page
      so that the new service worker can take over
      and serve the fresh content
    */
    window.addEventListener('swUpdate', () => {
      this.toastCtrl
        .create({
          message: 'New version available',
          showCloseButton: true,
          closeButtonText: 'Reload'
        })
        .then(toast => {
          toast.present()
        })
    })
  }
}
