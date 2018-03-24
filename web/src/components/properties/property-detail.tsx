import '@ionic/core'
import '@stencil/core'

import { Component, Prop, State, Listen } from '@stencil/core'
import {
  IDatabaseInjector,
  Property,
  Unit
} from '../services/database-injector'

@Component({
  tag: 'property-detail'
})
export class PropertyDetail {
  @Prop() propertyId: string

  @Prop({ connect: 'database-injector' })
  dbInjector: IDatabaseInjector

  @Prop({ connect: 'ion-modal-controller' })
  modalCtrl: HTMLIonModalControllerElement

  @State() property: Property
  @State() units: Unit[] = []
  unsub: () => void

  async componentDidLoad() {
    const db = await this.dbInjector.create()
    this.property = await db.property(this.propertyId)
    this.unsub = await db.units(this.property.id, units => {
      this.units = units
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
    console.log(event)
    /*
    if (event) {
      this.excludeTracks = event.detail.data;
      this.updateSchedule();
    } */
  }

  render() {
    return [
      <ion-page>
        <ion-header>
          <ion-toolbar>
            <ion-buttons slot="start">
              <ion-back-button defaultHref="/properties" />
            </ion-buttons>
            <ion-title>{this.property && this.property.name}</ion-title>
            <ion-buttons slot="end">
              <more-popover-button />
            </ion-buttons>
          </ion-toolbar>
        </ion-header>
        <ion-content>
          <p>Property detail</p>
          <ion-list>
            <ion-list-header>UNITS</ion-list-header>
            {this.units.map(u => (
              <ion-item href={`/properties/${this.property.id}/units/${u.id}`}>
                <ion-label>{u.address}</ion-label>
              </ion-item>
            ))}
          </ion-list>
        </ion-content>
      </ion-page>
    ]
  }
}
