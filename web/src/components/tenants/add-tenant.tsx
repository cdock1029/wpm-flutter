import { Component, Element, State } from '@stencil/core'
import { Tenant } from '../services/database-injector'

@Component({
  tag: 'add-tenant',
  styleUrl: 'add-tenant.scss'
})
export class AddTenant {
  @Element() el: any

  @State() firstName = { value: null, valid: false }

  @State() lastName = { value: null, valid: false }

  @State() submitted = false

  dismiss = (tenant?: Tenant) => {
    const modal = this.el.closest('ion-modal')
    modal.dismiss(tenant)
  }

  onSaveTenant = (e: MouseEvent) => {
    e.preventDefault()
    this.validateFirstName()
    this.validateLastName()
    this.submitted = true

    if (this.firstName.valid && this.lastName.valid) {
      this.dismiss({
        firstName: this.firstName.value,
        lastName: this.lastName.value
      })
    }
  }
  onFirstInput = e => {
    this.firstName = {
      ...this.firstName,
      value: e.target.value
    }
    this.validateFirstName()
  }
  onLastInput = e => {
    this.lastName = {
      ...this.lastName,
      value: e.target.value
    }
    this.validateLastName()
  }
  validateFirstName() {
    console.log('validation firstName=', this.firstName.value)
    if (this.firstName.value && this.firstName.value.trim().length > 0) {
      this.firstName = {
        ...this.firstName,
        valid: true
      }
      return
    }
    this.firstName = {
      ...this.firstName,
      valid: false
    }
  }
  validateLastName() {
    console.log('validation lastName=', this.lastName.value)
    if (this.lastName.value && this.lastName.value.trim().length > 0) {
      this.lastName = {
        ...this.lastName,
        valid: true
      }
      return
    }
    this.lastName = {
      ...this.lastName,
      valid: false
    }
  }

  render() {
    return [
      <ion-page>
        <ion-header>
          <ion-toolbar color="danger">
            <ion-buttons slot="left">
              <ion-button onClick={() => this.dismiss()}>CANCEL</ion-button>
            </ion-buttons>

            <ion-title>Add Tenant</ion-title>
          </ion-toolbar>
        </ion-header>
        <ion-content>
          <form novalidate>
            <ion-list>
              <ion-item>
                <ion-label fixed>First name</ion-label>
                <ion-input
                  name="firstName"
                  value={this.firstName.value}
                  type="text"
                  onInput={this.onFirstInput}
                  autofocus={true}
                  required
                />
              </ion-item>
              <ion-text color="danger">
                <p
                  hidden={this.firstName.valid || this.submitted === false}
                  padding-left
                >
                  Valid first name is required
                </p>
              </ion-text>
              <ion-item>
                <ion-label fixed>Last name</ion-label>
                <ion-input
                  name="lastName"
                  value={this.lastName.value}
                  type="text"
                  onInput={this.onLastInput}
                  autofocus={true}
                  required
                />
              </ion-item>
              <ion-text color="danger">
                <p
                  hidden={this.lastName.valid || this.submitted === false}
                  padding-left
                >
                  Valid Last name is required
                </p>
              </ion-text>

              <div padding>
                <ion-button
                  onClick={this.onSaveTenant}
                  expand="block"
                  type="submit"
                >
                  SAVE
                </ion-button>
              </div>
            </ion-list>
          </form>
        </ion-content>
      </ion-page>
    ]
  }
}
