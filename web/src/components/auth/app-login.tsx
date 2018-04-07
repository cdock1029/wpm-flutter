import { Component, Prop, State } from '@stencil/core'

import { IDatabaseInjector, IDatabase } from '../services/database-injector'

@Component({ tag: 'app-login', styleUrl: 'app-login.scss' })
export class AppLogin {
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
    try {
      const user = await this.db.signIn(this.username, this.password)
      if (user) {
        console.log('login returned user, nav setting root..')
        window.location.replace('/')
      }
    } catch (e) {
      console.log(e)
      this.error = e.message
    }
  }

  render() {
    return [
      <ion-header>
        <ion-toolbar color="primary">
          <ion-buttons slot="start">
            <ion-menu-button />
          </ion-buttons>
          <ion-title>WPM</ion-title>
        </ion-toolbar>
      </ion-header>,

      <ion-content>
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

            <ion-item padding>
              <ion-label floating color="primary">
                EMAIL
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

            <ion-item padding>
              <ion-label stacked color="primary">
                PASSWORD
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

          <div padding>
            <ion-button
              size="large"
              onClick={this.onLogin}
              type="submit"
              expand="block"
            >
              Login
            </ion-button>
            {/* <ion-col>
              <ion-button
                onClick={e => this.onSignup(e)}
                color="light"
                expand="block"
              >
                Signup
              </ion-button>
            </ion-col> */}
          </div>
        </form>
      </ion-content>
    ]
  }
}
