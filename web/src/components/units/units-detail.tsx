import { Component, Prop, State, Listen } from '@stencil/core'
import {
  IDatabaseInjector,
  Property,
  Unit,
  Lease
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
  @State() leases: Lease[] = []
  leasesUnsub: () => void

  async componentDidLoad() {
    const db = await this.dbInjector.create()
    const [property, unit, leasesUnsub] = await Promise.all([
      db.property(this.propertyId),
      db.unit({ propertyId: this.propertyId, unitId: this.unitId }),
      db.leasesForUnit(this.unitId, leases => {
        this.leases = leases
      })
    ])
    this.unit = unit
    this.property = property
    this.leasesUnsub = leasesUnsub
  }
  componentDidUnload() {
    if (this.leasesUnsub) {
      this.leasesUnsub()
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
    // const propName = this.property && this.property.name
    const unitAddr = this.unit && this.unit.address
    return [
      <ion-page>
        <ion-header>
          <ion-toolbar color="primary">
            <ion-buttons slot="start">
              <ion-back-button defaultHref={`/properties/${this.propertyId}`} />
            </ion-buttons>
            <ion-title>{unitAddr && unitAddr}</ion-title>
          </ion-toolbar>
        </ion-header>
        <ion-content>
          <p>Unit detail</p>
          <h3>{unitAddr}</h3>
          <ion-list>
            <ion-list-header>Leases</ion-list-header>
            {this.leases.map(l => [
              <ion-card>
                <ion-card-header>
                  <ion-card-title>Lease x</ion-card-title>
                  <ion-card-subtitle>subtitle</ion-card-subtitle>
                </ion-card-header>
                <ion-card-content>
                  <div>RENT: {l.rent}</div>
                  <div>BALANCE: {l.balance}</div>
                </ion-card-content>
              </ion-card>
            ])}
          </ion-list>
        </ion-content>
      </ion-page>
    ]
  }
}
