import { Component } from '@stencil/core'

const leases = [
  {
    propertyName: 'ACME Acres',
    unitLabel: 'A-101',
    tenantNames: [
      'Bunny, Bugs',
      'Duck, Daffy',
      'Bunny, Bugs',
      'Duck, Daffy',
      'Bunny, Bugs',
      'Duck, Daffy',
      'Bunny, Bugs',
      'Duck, Daffy'
    ],
    rent: '500',
    balance: '1500'
  },
  {
    propertyName: 'ACME Acres',
    unitLabel: 'B-201',
    tenantNames: ['Bird, Tweety'],
    rent: '450',
    balance: '0'
  }
]

@Component({
  tag: 'lease-table',
  styleUrl: 'lease-table.scss'
})
export class LeaseTable {
  render() {
    return (
      <ion-page>
        <ion-header>
          <common-toolbar title="LEASES" />
        </ion-header>
        <ion-content>
          {leases.map(l => (
            <ion-card>
              <ion-card-header>
                <ion-row justify-content-between>
                  <ion-column>
                    <ion-card-subtitle>{l.propertyName}</ion-card-subtitle>
                    <ion-card-title>{l.unitLabel}</ion-card-title>
                  </ion-column>

                  <ion-column>
                    <tenant-popover-button names={l.tenantNames} />
                  </ion-column>
                </ion-row>
                {/* <div class="tenants">
                </div> */}
              </ion-card-header>
              <ion-card-content>
                <ion-grid>
                  <ion-row justify-content-between>
                    <ion-column>{l.rent}</ion-column>
                    <ion-column>{l.balance}</ion-column>
                  </ion-row>
                </ion-grid>
              </ion-card-content>
            </ion-card>
          ))}
        </ion-content>
      </ion-page>
    )
  }
}
