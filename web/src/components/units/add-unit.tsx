import { Component, Prop, State } from '@stencil/core'
import { Unit } from '../services/database-injector'

@Component({
  tag: 'add-unit'
})
export class AddUnit {
  @Prop({ connect: 'ion-modal-controller' })
  modalCtrl: HTMLIonModalControllerElement

  @State() address = { value: null, valid: false }

  @State() submitted = false

  private modal

  async componentDidLoad() {
    this.modal = await this.modalCtrl.componentOnReady()
  }

  dismiss = (unit?: Unit) => {
    this.modal.dismiss(unit)
  }

  onSaveUnit = (e: MouseEvent) => {
    e.preventDefault()
    this.validateUnitAddress()
    this.submitted = true

    if (this.address.valid) {
      this.dismiss({ address: this.address.value })
    }
  }
  onInput = e => {
    this.address = {
      ...this.address,
      value: e.target.value
    }
    this.validateUnitAddress()
  }
  validateUnitAddress() {
    if (this.address.value && this.address.value.trim().length > 0) {
      this.address = {
        ...this.address,
        valid: true
      }
      return
    }
    this.address = {
      ...this.address,
      valid: false
    }
  }

  render() {
    return [
      <ion-page>
        <ion-header>
          <ion-toolbar color="primary">
            <ion-buttons slot="left">
              <ion-button onClick={() => this.dismiss()}>CANCEL</ion-button>
            </ion-buttons>
            <ion-title>Add Unit</ion-title>
          </ion-toolbar>
        </ion-header>
        <ion-content>
          <form novalidate>
            <ion-list>
              <ion-item>
                <ion-label fixed>Unit Address</ion-label>
                <ion-input
                  name="address"
                  value={this.address.value}
                  type="text"
                  onInput={this.onInput}
                  autofocus={true}
                  required
                />
              </ion-item>
              <ion-text color="danger">
                <p
                  hidden={this.address.valid || this.submitted === false}
                  padding-left
                >
                  Unit address is required
                </p>
              </ion-text>

              <div padding>
                <ion-button
                  onClick={this.onSaveUnit}
                  expand="block"
                  type="submit"
                  color="danger"
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
