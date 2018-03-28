import { Component, Prop, State } from '@stencil/core'

import { NavControllerBase } from '@ionic/core'
import { IDatabaseInjector, IDatabase } from '../services/database-injector'

@Component({ tag: 'app-login', styleUrl: 'app-login.scss' })
export class AppLogin {
  @Prop({ connect: 'ion-nav' })
  nav: NavControllerBase

  @Prop({ connect: 'database-injector' })
  dbInjector: IDatabaseInjector

  @State() username = ''
  @State() password = ''
  @State() error = ''

  private db: IDatabase

  componentWillLoad = async () => {
    this.db = await this.dbInjector.create()
  }

  handleUsername = e => {
    this.username = e.target.value
  }
  handlePassword = e => {
    this.password = e.target.value
  }

  onLogin = async e => {
    e.preventDefault()
    const navCtrl: NavControllerBase = await (this
      .nav as any).componentOnReady()
    try {
      const user = await this.db.signIn(this.username, this.password)
      if (user) {
        console.log('login returned user, nav setting root..')
        navCtrl.setRoot('page-tabs')
      }
    } catch (e) {
      console.log(e)
      this.error = e.message
    }
  }

  render() {
    return [
      <ion-header>
        <ion-toolbar>
          <ion-buttons slot="start">
            <ion-menu-button />
          </ion-buttons>

          <ion-title>Login</ion-title>
        </ion-toolbar>
      </ion-header>,

      <ion-content padding>
        {/* <div class="login-logo">
          <img src="assets/img/appicon.svg" alt="Ionic logo" />
        </div> */}

        <form novalidate>
          <ion-list no-lines>
            {this.error && (
              <ion-text color="danger">
                <p padding-left>Error signing in: {this.error}</p>
              </ion-text>
            )}

            <ion-item>
              <ion-label stacked color="primary">
                Username
              </ion-label>
              <ion-input
                name="username"
                type="email"
                value={this.username}
                onInput={this.handleUsername}
                spellcheck={false}
                autocapitalize="off"
                required
              />
            </ion-item>

            <ion-item>
              <ion-label stacked color="primary">
                Password
              </ion-label>
              <ion-input
                name="password"
                type="password"
                value={this.password}
                onInput={this.handlePassword}
                required
              />
            </ion-item>
          </ion-list>

          <ion-row responsive-sm>
            <ion-col>
              <ion-button onClick={this.onLogin} type="submit" expand="block">
                Login
              </ion-button>
            </ion-col>
            {/* <ion-col>
              <ion-button
                onClick={e => this.onSignup(e)}
                color="light"
                expand="block"
              >
                Signup
              </ion-button>
            </ion-col> */}
          </ion-row>
        </form>
      </ion-content>
    ]
  }
}
