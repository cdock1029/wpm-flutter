import { Component, Element, Prop, State } from '@stencil/core'
import { IDatabaseInjector, Property } from '../services/database-injector'

@Component({
  tag: 'property-popover'
})
export class PropertyPopover {
  @Element() el: HTMLElement

  @Prop({ connect: 'database-injector' })
  dbInjector: IDatabaseInjector

  @State() properties: Property[] = []
  unsub: () => void

  async componentDidLoad() {
    const db = await this.dbInjector.create()

    this.unsub = await db.properties((props: Property[]) => {
      this.properties = props
    })
  }

  componentWillUnload() {
    this.unsub()
  }

  dismiss = (pid: string) => {
    ;(this.el.closest('ion-popover') as any).dismiss(pid)
  }

  render() {
    return (
      <ion-list no-lines>
        <ion-list-header>Properties</ion-list-header>
        {this.properties.map(p => (
          <ion-item onClick={() => this.dismiss(p.id)}>{p.name}</ion-item>
        ))}
      </ion-list>
    )
  }
}
