import { Component, Prop, State, Listen } from '@stencil/core'
import {
  IDatabaseInjector,
  Property,
  Unit
} from '../services/database-injector'

@Component({
  tag: 'unit-detail'
})
export class UnitDetail {
  @Prop() propertyId: string
  @Prop() unitId: string

  @Prop({ connect: 'database-injector' })
  dbInjector: IDatabaseInjector

  @Prop({ connect: 'ion-modal-controller' })
  modalCtrl: HTMLIonModalControllerElement

  @State() unit: Unit
  @State() property: Property
  unsub: () => void

  async componentDidLoad() {
    const db = await this.dbInjector.create()
    const [property, unit] = await Promise.all([
      db.property(this.propertyId),
      db.unit({ propertyId: this.propertyId, unitId: this.unitId })
    ])
    this.unit = unit
    this.property = property
    /* this.unsub = await db.units(this.property.id, units => {
      this.units = units
    })*/
  }
  componentDidUnload() {
    if (this.unsub) {
      this.unsub()
    }
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
    const propName = this.property && this.property.name
    const unitAddr = this.unit && this.unit.address
    return [
      <ion-page>
        <ion-header>
          <ion-toolbar>
            <ion-buttons slot="start">
              <ion-back-button defaultHref={`/properties/${this.propertyId}`} />
            </ion-buttons>
            <ion-title>
              {propName && unitAddr && `${propName} / ${unitAddr}`}
            </ion-title>
            <ion-buttons slot="end">
              <more-popover-button />
            </ion-buttons>
          </ion-toolbar>
        </ion-header>
        <ion-content>
          <p>Unit detail</p>
          <h3>{unitAddr}</h3>
          <ion-list>
            <ion-list-header>Leases/Tenant/etc..</ion-list-header>
            {/* {this.units.map(u => (
              <ion-item>
                <ion-label>{u.address}</ion-label>
              </ion-item>
            ))} */}
          </ion-list>
        </ion-content>
      </ion-page>
    ]
  }
}
