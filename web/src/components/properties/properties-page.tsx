import { Component, Prop, State, Listen } from '@stencil/core'
import {
  IDatabaseInjector,
  IDatabase,
  Property
} from '../services/database-injector'

@Component({
  tag: 'properties-page'
})
export class PropertiesPage {
  @Prop({ connect: 'database-injector' })
  dbInjector: IDatabaseInjector

  @Prop({ connect: 'ion-modal-controller' })
  modalCtrl: HTMLIonModalControllerElement

  @State() properties: Property[] = []

  db: IDatabase
  unsub: () => void

  async componentDidLoad() {
    this.db = await this.dbInjector.create()

    this.unsub = await this.db.properties((props: Property[]) => {
      this.properties = props
    })
  }
  componentDidUnload() {
    this.unsub()
  }

  addPropertyModal = async () => {
    const modal = await this.modalCtrl.create({
      component: 'add-property'
    })
    await modal.present()
  }

  @Listen('body:ionModalDidDismiss')
  modalDidDismiss(event: CustomEvent) {
    const prop: Property | null = event.detail.data

    // console.log('prop=', prop)
    if (prop) {
      this.db.addProperty(prop)
    }
  }

  render() {
    return [
      <ion-page>
        <ion-header>
          <common-toolbar title="PROPERTIES" />
        </ion-header>
        <ion-content>
          <ion-list>
            <ion-list-header>List of Properties</ion-list-header>
            {this.properties.map(p => (
              <ion-item href={`/properties/${p.id}`}>
                <ion-label>{p.name}</ion-label>
              </ion-item>
            ))}
          </ion-list>
          <ion-fab
            id="addProperty"
            vertical="bottom"
            horizontal="end"
            slot="fixed"
          >
            <ion-fab-button onClick={this.addPropertyModal}>
              <ion-icon name="add" />
            </ion-fab-button>
          </ion-fab>
        </ion-content>
      </ion-page>
    ]
  }
}
