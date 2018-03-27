import '@ionic/core'
import '@stencil/core'

import { Component, Prop, Listen, State } from '@stencil/core'
import {
  NavControllerBase,
  ToastController,
  LoadingController
} from '@ionic/core'
import { FirebaseNamespace } from '@firebase/app-types'
import { User } from '@firebase/auth-types'

declare const firebase: FirebaseNamespace

@Component({
  tag: 'my-app',
  styleUrl: 'my-app.scss'
})
export class MyApp {
  @Prop({ connect: 'ion-toast-controller' })
  toastCtrl: ToastController

  @Prop({ connect: 'ion-nav' })
  nav: NavControllerBase

  @Prop({ connect: 'ion-loading-controller' })
  loadCtrl: LoadingController

  @State()
  user: {
    data: User
    loaded: boolean
  } = { data: null, loaded: false }

  private unsub
  private loadingEl: HTMLIonLoadingElement

  authStateChanged = async (user: User) => {
    console.log('handle authStateChange user? =>', Boolean(user))
    // await new Promise(resolve => setTimeout(resolve, 1000))
    await this.loadingEl.dismiss()
    this.user = {
      data: user,
      loaded: true
    }
  }

  async componentWillLoad() {
    this.loadingEl = await this.loadCtrl.create({
      content: 'Loading..',
      spinner: 'crescent',
      translucent: true
    })
    await this.loadingEl.present()
  }

  componentDidLoad() {
    const auth = firebase.auth()
    console.log('my-app componentWillLoad')
    this.unsub = auth.onAuthStateChanged(this.authStateChanged)

    console.log('my-app componentDidLoad')
    // const auth = await this.authInjector.create()
    const currentUser = auth.currentUser
    console.log(
      'my-app componentWillLoad currentUser => ',
      Boolean(currentUser)
    )
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
        <ion-route url="/login" component="app-login" />,
        <ion-route-redirect from="*" to={!this.user.data ? '/login' : null} />
        <ion-route url="/home" component="app-home" />
        <ion-route url="/properties" component="properties-page" />>
        <ion-route url="/properties/:propertyId" component="property-detail" />
        <ion-route
          url="/properties/:propertyId/units/:unitId"
          component="unit-detail"
        />
        <ion-route url="/tenants" component="tenants-page" />
        {/* <ion-route component="page-tabs">
          <ion-route url="/properties" component="tab-properties">
            <ion-route url="/:propertyId" component="property-detail" />
            <ion-route
              url="/:propertyId/units/:unitId"
              component="unit-detail"
            />
          </ion-route>
        </ion-route> */}
        <ion-route-redirect from="/" to="/home" />,
      </ion-router>
    )
  }

  render() {
    console.log(
      'render my-app / [isReady, userData]? =>',
      this.user.loaded,
      this.user.data
    )
    return !this.user.loaded ? null : (
      <ion-app>
        {this.renderRouter()}
        <ion-split-pane>
          <ion-menu>
            <ion-header>
              <ion-toolbar color="primary">
                <ion-title>WPM</ion-title>
              </ion-toolbar>
            </ion-header>
            <ion-content>
              <ion-list>
                {appPages.map(p => (
                  <ion-menu-toggle autoHide={false}>
                    <ion-item href={p.url}>
                      <ion-icon slot="start" name={p.icon} />
                      <ion-label>{p.title}</ion-label>
                    </ion-item>
                  </ion-menu-toggle>
                ))}
              </ion-list>
            </ion-content>
          </ion-menu>
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

const appPages = [
  {
    title: 'Home',
    url: '/home',
    icon: 'home'
  },
  {
    title: 'Properties',
    url: '/properties',
    icon: 'planet'
  },
  {
    title: 'Tenants',
    url: '/tenants',
    icon: 'people'
  }
]
