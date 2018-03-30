import { Component, Listen, Prop, State } from '@stencil/core'
import {
  IDatabaseInjector,
  IDatabase,
  Tenant
} from '../services/database-injector'

/* <logout-button /> */

@Component({
  tag: 'tenants-page'
})
export class TenantsPage {
  @Prop({ connect: 'database-injector' })
  dbInjector: IDatabaseInjector

  @Prop({ connect: 'ion-modal-controller' })
  modalCtrl: HTMLIonModalControllerElement

  @State() tenants: Tenant[] = []

  @State() filter: string

  db: IDatabase
  unsub: () => void

  async componentDidLoad() {
    this.db = await this.dbInjector.create()

    this.unsub = await this.db.tenants((tens: Tenant[]) => {
      this.tenants = tens
    })
  }
  componentDidUnload() {
    this.unsub()
  }
  addTenantModal = async () => {
    const modal = await this.modalCtrl.create({
      component: 'add-tenant'
    })
    await modal.present()
  }

  // @Listen('body:ionModalDidDismiss')
  // modalDidDismiss(event: CustomEvent) {
  //   const tenant: Tenant | null = event.detail.data

  //   if (tenant) {
  //     this.db.addTenant(tenant)
  //   }
  // }

  @Listen('ionInput')
  onIonInput(event: CustomEvent) {
    const el: HTMLInputElement = event.detail.srcElement
    console.log('ionInput value=', el.value)
    this.filter = el.value && el.value.toUpperCase()
  }

  render() {
    const tenants = this.filter
      ? this.tenants.filter(
          t =>
            t.firstName.toUpperCase().includes(this.filter) ||
            t.lastName.toUpperCase().includes(this.filter)
        )
      : this.tenants
    return (
      <ion-page>
        <ion-header>
          <common-toolbar title="TENANTS" />
        </ion-header>
        <ion-content>
          <ion-list>
            <ion-list-header>Tenants</ion-list-header>
            {tenants.map(t => (
              <ion-item>
                <ion-label>
                  {t.lastName}, {t.firstName}
                </ion-label>
              </ion-item>
            ))}
          </ion-list>
          <ion-fab
            id="addTenant"
            vertical="bottom"
            horizontal="end"
            slot="fixed"
          >
            <ion-fab-button onClick={this.addTenantModal}>
              <ion-icon name="add" />
            </ion-fab-button>
          </ion-fab>
        </ion-content>
      </ion-page>
    )
  }
}
