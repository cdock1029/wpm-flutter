import { Component, Prop, State } from '@stencil/core'
import {
  IDatabaseInjector,
  IDatabase,
  Property,
  AppUser
} from '../services/database-injector'

@Component({
  tag: 'nav-menu'
})
export class NavMenu {
  @Prop({ connect: 'database-injector' })
  dbInjector: IDatabaseInjector

  @Prop() appUser: AppUser

  @State() properties: Property[] = []

  private db: IDatabase
  private unsub: () => void

  async componentWillLoad() {
    this.db = await this.dbInjector.create()
    this.unsub = await this.db.properties((props: Property[]) => {
      this.properties = props
    })
  }

  componentDidUnload() {
    if (this.unsub) {
      this.unsub()
    }
  }

  render() {
    console.log('page tabs render')
    const { authData } = this.appUser
    return [
      <ion-list>
        <ion-list-header>USER: {authData && authData.email}</ion-list-header>
      </ion-list>,
      <ion-list no-lines>
        <ion-list-header>
          <ion-icon name="home" slot="start" padding-right />
          <ion-label>PROPERTIES</ion-label>
        </ion-list-header>
        {this.properties.map(p => (
          <ion-menu-toggle autoHide={false}>
            <ion-item href={`/properties/${p.id}`}>
              {/* <ion-icon name="home" slot="start" /> */}
              <ion-label>{p.name}</ion-label>
            </ion-item>
          </ion-menu-toggle>
        ))}
      </ion-list>
    ]
  }
}
