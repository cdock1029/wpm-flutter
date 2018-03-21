import '@ionic/core'
import '@stencil/core'
import { Component, Prop, Listen, State } from '@stencil/core'
import { NavControllerBase, ToastController } from '@ionic/core'
import { AuthInjector } from '../services/auth-injector'
import { User } from '@firebase/auth-types'

@Component({
  tag: 'my-app',
  styleUrl: 'my-app.scss'
})
export class MyApp {
  @Prop({ connect: 'ion-toast-controller' })
  toastCtrl: ToastController

  @Prop({ connect: 'auth-injector' })
  authInjector: AuthInjector

  @Prop({ connect: 'ion-nav' })
  nav: NavControllerBase

  private unsub
  @State()
  user: {
    data: User
    loaded: boolean
  } = { data: null, loaded: false }

  // private auth: FirebaseAuth

  // @Listen('window:popstate')
  // handlePopState(e) {
  //   console.log('window:popstate e=', e)
  // }

  authStateChanged = (user: User) => {
    console.log('handle authStateChange user=', user)
    this.user = {
      data: user,
      loaded: true
    }
    // const navCtrl: NavControllerBase = await (this
    //   .nav as any).componentOnReady()

    // navCtrl.setRoot(user ? 'page-tabs' : 'app-login', null, {
    //   animate: true,
    //   direction: 'forward'
    // })
  }

  appPages = [
    {
      title: 'Home',
      url: '/',
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

  async componentWillLoad() {
    const auth = await this.authInjector.create()
    this.unsub = auth.onAuthStateChanged(this.authStateChanged)
  }

  componentDidLoad() {
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

  componentDidUnload() {
    if (this.unsub) {
      console.log('unsubbing')
      this.unsub()
    }
  }

  @Listen('body:ionToastWillDismiss')
  reload() {
    window.location.reload()
  }

  renderRouter = () => {
    const doRedirect = this.user.loaded && !this.user.data
    console.log('render router doRedirect?', doRedirect)
    return (
      <ion-router useHash={false}>
        {doRedirect ? (
          <ion-route-redirect from="*" to={doRedirect ? '/login' : null} />
        ) : null}
        <ion-route component="page-tabs">
          {/* {doRedirect ? (
            <ion-route-redirect
              from={window.location.pathname}
              to={doRedirect ? '/login' : null}
            />
          ) : null} */}
          <ion-route url="/" component="app-home" />
          <ion-route url="/properties" component="properties-page" />
          <ion-route url="/tenants" component="tenants-page" />
        </ion-route>

        <ion-route url="/login" component="app-login" />
        <ion-route url="/profile/:name" component="app-profile" />
      </ion-router>
    )
  }

  render() {
    console.log('render my-app')
    return this.user.loaded ? (
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
                {this.appPages.map(p => (
                  <ion-menu-toggle autoHide={false}>
                    <ion-item href={p.url}>
                      <ion-icon slot="start" name={p.icon} />
                      <ion-label>{p.title}</ion-label>
                    </ion-item>
                  </ion-menu-toggle>
                ))}
              </ion-list>
              <ion-item-divider />
            </ion-content>
          </ion-menu>
          <ion-nav swipeBackEnabled={false} main />
        </ion-split-pane>
      </ion-app>
    ) : (
      <ion-app>
        <ion-page>
          <h3>Loading..</h3>
        </ion-page>
      </ion-app>
    )
  }
}
