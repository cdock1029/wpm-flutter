import { Component, Prop, State } from '@stencil/core'
import {
  IDatabaseInjector,
  IDatabase,
  Property,
  Unit
} from '../services/database-injector'
import { Nav, OverlayEventDetail } from '@ionic/core'

@Component({
  tag: 'property-detail'
})
export class PropertyDetail {
  @Prop() propertyId: string

  @Prop({ connect: 'ion-nav' })
  nav
  navCtrl: Nav

  @Prop({ connect: 'database-injector' })
  dbInjector: IDatabaseInjector
  private db: IDatabase

  @Prop({ connect: 'ion-modal-controller' })
  modalCtrl: HTMLIonModalControllerElement

  @State() property: Property
  @State() units: Unit[] = []
  private unitsUnsub: () => void

  async componentWillLoad() {
    console.log('property detail propertyId=', this.propertyId)
    this.navCtrl = await this.nav.componentOnReady()
    console.log('navCtrl =>', this.navCtrl)
  }

  async componentDidLoad() {
    this.db = await this.dbInjector.create()
    const [prop, unitsUnsub] = await Promise.all([
      this.db.property(this.propertyId),
      this.db.units(this.propertyId, units => {
        this.units = units
      })
    ])
    this.property = prop
    this.unitsUnsub = unitsUnsub
  }
  componentDidUnload() {
    if (this.unitsUnsub) {
      this.unitsUnsub()
    }
  }

  addUnitModal = async () => {
    const modal = await this.modalCtrl.create({
      component: 'add-unit'
    })
    modal.onDidDismiss(this.modalDidDismiss)
    await modal.present()
  }

  modalDidDismiss = (detail: OverlayEventDetail) => {
    const unit: Unit | null = detail.data
    if (unit) {
      this.db.addUnit(unit, this.propertyId)
    }
  }

  render() {
    return [
      <ion-page>
        <ion-header>
          <ion-toolbar color="primary">
            <ion-buttons slot="start">
              <ion-back-button defaultHref="/properties" />
            </ion-buttons>
            <ion-title>{this.property && this.property.name}</ion-title>
            {/* <ion-buttons slot="end">
              <more-popover-button />
            </ion-buttons> */}
          </ion-toolbar>
        </ion-header>
        <ion-content>
          <p>Property detail</p>
          <ion-list>
            <ion-list-header>UNITS</ion-list-header>
            {this.units.map(u => (
              <ion-item href={`/properties/${this.propertyId}/units/${u.id}`}>
                <ion-label>{u.address}</ion-label>
              </ion-item>
            ))}
          </ion-list>
          <ion-fab id="addUnit" vertical="bottom" horizontal="end" slot="fixed">
            <ion-fab-button onClick={this.addUnitModal} color="danger">
              <ion-icon name="add" />
            </ion-fab-button>
          </ion-fab>
        </ion-content>
      </ion-page>
    ]
  }
}
