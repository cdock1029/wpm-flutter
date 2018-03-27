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

  @Listen('body:ionModalDidDismiss')
  modalDidDismiss(event: CustomEvent) {
    const tenant: Tenant | null = event.detail.data

    // console.log('prop=', prop)
    if (tenant) {
      this.db.addTenant(tenant)
    }
  }
  render() {
    return (
      <ion-page>
        <ion-header>
          <ion-toolbar>
            <ion-buttons slot="start">
              <ion-menu-button />
            </ion-buttons>
            <ion-title>Tenants</ion-title>
            <ion-buttons slot="end">
              <more-popover-button />
            </ion-buttons>
          </ion-toolbar>
        </ion-header>
        <ion-content>
          <ion-list>
            <ion-list-header>Tenants</ion-list-header>
            {this.tenants.map(t => (
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
