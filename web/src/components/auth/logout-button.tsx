import { Component, Prop } from '@stencil/core'
import { NavControllerBase } from '@ionic/core'

import { IDatabase, IDatabaseInjector } from '../services/database-injector'

@Component({
  tag: 'logout-button'
})
export class LogoutButton {
  @Prop({ connect: 'ion-nav' })
  nav: NavControllerBase

  @Prop({ connect: 'database-injector' })
  dbInjector: IDatabaseInjector
  private db: IDatabase

  async componentWillLoad() {
    this.db = await this.dbInjector.create()
  }

  logOutHandler = async () => {
    console.log('logouthandler click')
    const navCtrl: NavControllerBase = await (this
      .nav as any).componentOnReady()

    await this.db.signOut()

    navCtrl.setRoot('app-login')
  }

  render() {
    return [
      <ion-button onClick={this.logOutHandler}>
        <ion-icon slot="icon-only" name="log-out" />
      </ion-button>
    ]
  }
}
