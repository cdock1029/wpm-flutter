import { Component, Element } from '@stencil/core'

@Component({
  tag: 'more-popover',
  styleUrl: 'more-popover.scss'
})
export class MorePopover {
  @Element() el: HTMLElement

  componentWillUnload() {}

  dismiss = (doSignOut?: boolean) => {
    ;(this.el.closest('ion-popover') as any).dismiss(doSignOut)
  }

  render() {
    return (
      <ion-list class="list-no-md">
        <ion-item onClick={() => this.dismiss(true)}>
          <ion-icon name="log-out" slot="start" />
          <ion-label>LOG OUT</ion-label>
        </ion-item>
      </ion-list>
    )
  }
}
