import { Component, Prop, State } from '@stencil/core'
import {
  IDatabaseInjector,
  IDatabase,
  Property
} from '../services/database-injector'

@Component({
  tag: 'nav-menu'
})
export class NavMenu {
  @Prop({ connect: 'database-injector' })
  dbInjector: IDatabaseInjector

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
    this.unsub()
  }

  render() {
    console.log('page tabs render')

    return (
      <ion-list no-lines>
        <ion-list-header>PROPERTIES</ion-list-header>
        {this.properties.map(p => (
          <ion-menu-toggle>
            <ion-item href={`/properties/${p.id}`}>
              <ion-icon name="home" slot="start" />
              <ion-label>{p.name}</ion-label>
            </ion-item>
          </ion-menu-toggle>
        ))}
      </ion-list>
    )
  }
}
