import { Component, Prop } from '@stencil/core'
import { User } from '../services/database-injector'

@Component({
  tag: 'nav-menu'
})
export class NavMenu {
  @Prop() user: User

  render() {
    return [
      <ion-list>
        <ion-list-header>USER: {this.user.email}</ion-list-header>
      </ion-list>,
      <ion-list no-lines>
        {appPages.map(page => (
          <ion-menu-toggle autoHide={false} menu="left">
            <ion-item href={page.url}>
              <ion-icon name={page.icon} slot="start" />
              <ion-label>{page.title}</ion-label>
            </ion-item>
          </ion-menu-toggle>
        ))}
      </ion-list>
    ]
  }
}

const appPages = [
  {
    title: 'Home',
    url: '/',
    icon: 'planet'
  },
  {
    title: 'Properties',
    url: '/properties',
    icon: 'home'
  },
  {
    title: 'Tenants',
    url: '/tenants',
    icon: 'people'
  },
  {
    title: 'Leases',
    url: '/leases',
    icon: 'paper'
  }
]
