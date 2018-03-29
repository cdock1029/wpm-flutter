import { Component, Prop, State } from '@stencil/core'
import { Property } from '../services/database-injector'

@Component({
  tag: 'add-property'
})
export class AddProperty {
  @Prop({ connect: 'ion-modal-controller' })
  modalCtrl: HTMLIonModalControllerElement

  @State() name = { value: null, valid: false }

  @State() submitted = false

  private modal

  async componentDidLoad() {
    this.modal = await this.modalCtrl.componentOnReady()
  }

  dismiss = (prop?: Property) => {
    // const modal = this.el.closest('ion-modal')
    this.modal.dismiss(prop)
  }

  onSaveProperty = (e: MouseEvent) => {
    e.preventDefault()
    this.validatePropertyName()
    this.submitted = true

    if (this.name.valid) {
      this.dismiss({ name: this.name.value })
    }
  }
  onInput = e => {
    this.name = {
      ...this.name,
      value: e.target.value
    }
    this.validatePropertyName()
  }
  validatePropertyName() {
    console.log('validation name=', this.name.value)
    if (this.name.value && this.name.value.trim().length > 0) {
      this.name = {
        ...this.name,
        valid: true
      }
      return
    }
    this.name = {
      ...this.name,
      valid: false
    }
  }

  render() {
    return [
      <ion-page>
        <ion-header>
          <ion-toolbar color="secondary">
            <ion-buttons slot="left">
              <ion-button onClick={() => this.dismiss()}>CANCEL</ion-button>
            </ion-buttons>
            <ion-title>Add Property</ion-title>
          </ion-toolbar>
        </ion-header>
        <ion-content>
          <form novalidate>
            <ion-list>
              <ion-item>
                <ion-label fixed>Property name</ion-label>
                <ion-input
                  name="name"
                  value={this.name.value}
                  type="text"
                  onInput={this.onInput}
                  autofocus={true}
                  required
                />
              </ion-item>
              <ion-text color="danger">
                <p
                  hidden={this.name.valid || this.submitted === false}
                  padding-left
                >
                  Username is required
                </p>
              </ion-text>

              <div padding>
                <ion-button
                  onClick={this.onSaveProperty}
                  expand="block"
                  type="submit"
                  color="secondary"
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
