/**
 * This is an autogenerated file created by the Stencil build process.
 * It contains typing information for all components that exist in this project
 * and imports for stencil collections that might be configured in your stencil.config.js file
 */

import '@stencil/core';

declare global {
  namespace JSX {
    interface Element {}
    export interface IntrinsicElements {}
  }
  namespace JSXElements {}

  interface HTMLStencilElement extends HTMLElement {
    componentOnReady(): Promise<this>;
    componentOnReady(done: (ele?: this) => void): void;

    forceUpdate(): void;
  }

  interface HTMLAttributes {}
}

import 'ionicons';
import '@ionic/core';

import {
  EventEmitter,
} from '@stencil/core';
import {
  IDatabase,
} from './components/services/database-injector';

declare global {
  interface HTMLAppHomeElement extends HTMLStencilElement {

  }
  var HTMLAppHomeElement: {
    prototype: HTMLAppHomeElement;
    new (): HTMLAppHomeElement;
  };
  interface HTMLElementTagNameMap {
    'app-home': HTMLAppHomeElement;
  }
  interface ElementTagNameMap {
    'app-home': HTMLAppHomeElement;
  }
  namespace JSX {
    interface IntrinsicElements {
      'app-home': JSXElements.AppHomeAttributes;
    }
  }
  namespace JSXElements {
    export interface AppHomeAttributes extends HTMLAttributes {

    }
  }
}


declare global {
  interface HTMLMyAppElement extends HTMLStencilElement {

  }
  var HTMLMyAppElement: {
    prototype: HTMLMyAppElement;
    new (): HTMLMyAppElement;
  };
  interface HTMLElementTagNameMap {
    'my-app': HTMLMyAppElement;
  }
  interface ElementTagNameMap {
    'my-app': HTMLMyAppElement;
  }
  namespace JSX {
    interface IntrinsicElements {
      'my-app': JSXElements.MyAppAttributes;
    }
  }
  namespace JSXElements {
    export interface MyAppAttributes extends HTMLAttributes {

    }
  }
}


declare global {
  interface HTMLPageTabsElement extends HTMLStencilElement {

  }
  var HTMLPageTabsElement: {
    prototype: HTMLPageTabsElement;
    new (): HTMLPageTabsElement;
  };
  interface HTMLElementTagNameMap {
    'page-tabs': HTMLPageTabsElement;
  }
  interface ElementTagNameMap {
    'page-tabs': HTMLPageTabsElement;
  }
  namespace JSX {
    interface IntrinsicElements {
      'page-tabs': JSXElements.PageTabsAttributes;
    }
  }
  namespace JSXElements {
    export interface PageTabsAttributes extends HTMLAttributes {

    }
  }
}


declare global {
  interface HTMLAppLoginElement extends HTMLStencilElement {

  }
  var HTMLAppLoginElement: {
    prototype: HTMLAppLoginElement;
    new (): HTMLAppLoginElement;
  };
  interface HTMLElementTagNameMap {
    'app-login': HTMLAppLoginElement;
  }
  interface ElementTagNameMap {
    'app-login': HTMLAppLoginElement;
  }
  namespace JSX {
    interface IntrinsicElements {
      'app-login': JSXElements.AppLoginAttributes;
    }
  }
  namespace JSXElements {
    export interface AppLoginAttributes extends HTMLAttributes {

    }
  }
}


declare global {
  interface HTMLLogoutButtonElement extends HTMLStencilElement {

  }
  var HTMLLogoutButtonElement: {
    prototype: HTMLLogoutButtonElement;
    new (): HTMLLogoutButtonElement;
  };
  interface HTMLElementTagNameMap {
    'logout-button': HTMLLogoutButtonElement;
  }
  interface ElementTagNameMap {
    'logout-button': HTMLLogoutButtonElement;
  }
  namespace JSX {
    interface IntrinsicElements {
      'logout-button': JSXElements.LogoutButtonAttributes;
    }
  }
  namespace JSXElements {
    export interface LogoutButtonAttributes extends HTMLAttributes {

    }
  }
}


declare global {
  interface HTMLLoadingSpinnerElement extends HTMLStencilElement {

  }
  var HTMLLoadingSpinnerElement: {
    prototype: HTMLLoadingSpinnerElement;
    new (): HTMLLoadingSpinnerElement;
  };
  interface HTMLElementTagNameMap {
    'loading-spinner': HTMLLoadingSpinnerElement;
  }
  interface ElementTagNameMap {
    'loading-spinner': HTMLLoadingSpinnerElement;
  }
  namespace JSX {
    interface IntrinsicElements {
      'loading-spinner': JSXElements.LoadingSpinnerAttributes;
    }
  }
  namespace JSXElements {
    export interface LoadingSpinnerAttributes extends HTMLAttributes {

    }
  }
}


declare global {
  interface HTMLMorePopoverButtonElement extends HTMLStencilElement {

  }
  var HTMLMorePopoverButtonElement: {
    prototype: HTMLMorePopoverButtonElement;
    new (): HTMLMorePopoverButtonElement;
  };
  interface HTMLElementTagNameMap {
    'more-popover-button': HTMLMorePopoverButtonElement;
  }
  interface ElementTagNameMap {
    'more-popover-button': HTMLMorePopoverButtonElement;
  }
  namespace JSX {
    interface IntrinsicElements {
      'more-popover-button': JSXElements.MorePopoverButtonAttributes;
    }
  }
  namespace JSXElements {
    export interface MorePopoverButtonAttributes extends HTMLAttributes {

    }
  }
}


declare global {
  interface HTMLMorePopoverElement extends HTMLStencilElement {

  }
  var HTMLMorePopoverElement: {
    prototype: HTMLMorePopoverElement;
    new (): HTMLMorePopoverElement;
  };
  interface HTMLElementTagNameMap {
    'more-popover': HTMLMorePopoverElement;
  }
  interface ElementTagNameMap {
    'more-popover': HTMLMorePopoverElement;
  }
  namespace JSX {
    interface IntrinsicElements {
      'more-popover': JSXElements.MorePopoverAttributes;
    }
  }
  namespace JSXElements {
    export interface MorePopoverAttributes extends HTMLAttributes {

    }
  }
}


declare global {
  interface HTMLPropertyPopoverButtonElement extends HTMLStencilElement {

  }
  var HTMLPropertyPopoverButtonElement: {
    prototype: HTMLPropertyPopoverButtonElement;
    new (): HTMLPropertyPopoverButtonElement;
  };
  interface HTMLElementTagNameMap {
    'property-popover-button': HTMLPropertyPopoverButtonElement;
  }
  interface ElementTagNameMap {
    'property-popover-button': HTMLPropertyPopoverButtonElement;
  }
  namespace JSX {
    interface IntrinsicElements {
      'property-popover-button': JSXElements.PropertyPopoverButtonAttributes;
    }
  }
  namespace JSXElements {
    export interface PropertyPopoverButtonAttributes extends HTMLAttributes {

    }
  }
}


declare global {
  interface HTMLPropertyPopoverElement extends HTMLStencilElement {

  }
  var HTMLPropertyPopoverElement: {
    prototype: HTMLPropertyPopoverElement;
    new (): HTMLPropertyPopoverElement;
  };
  interface HTMLElementTagNameMap {
    'property-popover': HTMLPropertyPopoverElement;
  }
  interface ElementTagNameMap {
    'property-popover': HTMLPropertyPopoverElement;
  }
  namespace JSX {
    interface IntrinsicElements {
      'property-popover': JSXElements.PropertyPopoverAttributes;
    }
  }
  namespace JSXElements {
    export interface PropertyPopoverAttributes extends HTMLAttributes {

    }
  }
}


declare global {
  interface HTMLLazyImgElement extends HTMLStencilElement {
    'alt': string;
    'src': string;
  }
  var HTMLLazyImgElement: {
    prototype: HTMLLazyImgElement;
    new (): HTMLLazyImgElement;
  };
  interface HTMLElementTagNameMap {
    'lazy-img': HTMLLazyImgElement;
  }
  interface ElementTagNameMap {
    'lazy-img': HTMLLazyImgElement;
  }
  namespace JSX {
    interface IntrinsicElements {
      'lazy-img': JSXElements.LazyImgAttributes;
    }
  }
  namespace JSXElements {
    export interface LazyImgAttributes extends HTMLAttributes {
      'alt'?: string;
      'onLazyImgloaded'?: (event: CustomEvent<HTMLImageElement>) => void;
      'src'?: string;
    }
  }
}


declare global {
  interface HTMLAddPropertyElement extends HTMLStencilElement {

  }
  var HTMLAddPropertyElement: {
    prototype: HTMLAddPropertyElement;
    new (): HTMLAddPropertyElement;
  };
  interface HTMLElementTagNameMap {
    'add-property': HTMLAddPropertyElement;
  }
  interface ElementTagNameMap {
    'add-property': HTMLAddPropertyElement;
  }
  namespace JSX {
    interface IntrinsicElements {
      'add-property': JSXElements.AddPropertyAttributes;
    }
  }
  namespace JSXElements {
    export interface AddPropertyAttributes extends HTMLAttributes {

    }
  }
}


declare global {
  interface HTMLPropertiesPageElement extends HTMLStencilElement {

  }
  var HTMLPropertiesPageElement: {
    prototype: HTMLPropertiesPageElement;
    new (): HTMLPropertiesPageElement;
  };
  interface HTMLElementTagNameMap {
    'properties-page': HTMLPropertiesPageElement;
  }
  interface ElementTagNameMap {
    'properties-page': HTMLPropertiesPageElement;
  }
  namespace JSX {
    interface IntrinsicElements {
      'properties-page': JSXElements.PropertiesPageAttributes;
    }
  }
  namespace JSXElements {
    export interface PropertiesPageAttributes extends HTMLAttributes {

    }
  }
}


declare global {
  interface HTMLPropertyDetailElement extends HTMLStencilElement {
    'propertyId': string;
  }
  var HTMLPropertyDetailElement: {
    prototype: HTMLPropertyDetailElement;
    new (): HTMLPropertyDetailElement;
  };
  interface HTMLElementTagNameMap {
    'property-detail': HTMLPropertyDetailElement;
  }
  interface ElementTagNameMap {
    'property-detail': HTMLPropertyDetailElement;
  }
  namespace JSX {
    interface IntrinsicElements {
      'property-detail': JSXElements.PropertyDetailAttributes;
    }
  }
  namespace JSXElements {
    export interface PropertyDetailAttributes extends HTMLAttributes {
      'propertyId'?: string;
    }
  }
}


declare global {
  interface HTMLPropertyTabsElement extends HTMLStencilElement {

  }
  var HTMLPropertyTabsElement: {
    prototype: HTMLPropertyTabsElement;
    new (): HTMLPropertyTabsElement;
  };
  interface HTMLElementTagNameMap {
    'property-tabs': HTMLPropertyTabsElement;
  }
  interface ElementTagNameMap {
    'property-tabs': HTMLPropertyTabsElement;
  }
  namespace JSX {
    interface IntrinsicElements {
      'property-tabs': JSXElements.PropertyTabsAttributes;
    }
  }
  namespace JSXElements {
    export interface PropertyTabsAttributes extends HTMLAttributes {

    }
  }
}


declare global {
  interface HTMLDatabaseInjectorElement extends HTMLStencilElement {
    'create': () => Promise<IDatabase>;
  }
  var HTMLDatabaseInjectorElement: {
    prototype: HTMLDatabaseInjectorElement;
    new (): HTMLDatabaseInjectorElement;
  };
  interface HTMLElementTagNameMap {
    'database-injector': HTMLDatabaseInjectorElement;
  }
  interface ElementTagNameMap {
    'database-injector': HTMLDatabaseInjectorElement;
  }
  namespace JSX {
    interface IntrinsicElements {
      'database-injector': JSXElements.DatabaseInjectorAttributes;
    }
  }
  namespace JSXElements {
    export interface DatabaseInjectorAttributes extends HTMLAttributes {

    }
  }
}


declare global {
  interface HTMLAddTenantElement extends HTMLStencilElement {

  }
  var HTMLAddTenantElement: {
    prototype: HTMLAddTenantElement;
    new (): HTMLAddTenantElement;
  };
  interface HTMLElementTagNameMap {
    'add-tenant': HTMLAddTenantElement;
  }
  interface ElementTagNameMap {
    'add-tenant': HTMLAddTenantElement;
  }
  namespace JSX {
    interface IntrinsicElements {
      'add-tenant': JSXElements.AddTenantAttributes;
    }
  }
  namespace JSXElements {
    export interface AddTenantAttributes extends HTMLAttributes {

    }
  }
}


declare global {
  interface HTMLTenantsPageElement extends HTMLStencilElement {

  }
  var HTMLTenantsPageElement: {
    prototype: HTMLTenantsPageElement;
    new (): HTMLTenantsPageElement;
  };
  interface HTMLElementTagNameMap {
    'tenants-page': HTMLTenantsPageElement;
  }
  interface ElementTagNameMap {
    'tenants-page': HTMLTenantsPageElement;
  }
  namespace JSX {
    interface IntrinsicElements {
      'tenants-page': JSXElements.TenantsPageAttributes;
    }
  }
  namespace JSXElements {
    export interface TenantsPageAttributes extends HTMLAttributes {

    }
  }
}


declare global {
  interface HTMLUnitDetailElement extends HTMLStencilElement {
    'propertyId': string;
    'unitId': string;
  }
  var HTMLUnitDetailElement: {
    prototype: HTMLUnitDetailElement;
    new (): HTMLUnitDetailElement;
  };
  interface HTMLElementTagNameMap {
    'unit-detail': HTMLUnitDetailElement;
  }
  interface ElementTagNameMap {
    'unit-detail': HTMLUnitDetailElement;
  }
  namespace JSX {
    interface IntrinsicElements {
      'unit-detail': JSXElements.UnitDetailAttributes;
    }
  }
  namespace JSXElements {
    export interface UnitDetailAttributes extends HTMLAttributes {
      'propertyId'?: string;
      'unitId'?: string;
    }
  }
}

declare global { namespace JSX { interface StencilJSX {} } }
