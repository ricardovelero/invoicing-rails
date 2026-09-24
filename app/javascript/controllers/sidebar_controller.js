import { Controller } from "@hotwired/stimulus";

// App-shell sidebar state, migrated off the Alpine `x-data` that used to live
// on <body>. It is registered on <body> so the navbar hamburger and the sidebar
// drawer/backdrop (rendered from separate partials) share one controller scope.
//
// Owns the mobile drawer (`open`, persisted in sessionStorage) and the desktop
// collapsed/expanded rail (`expanded`, persisted in localStorage, driving the
// `sidebar-expanded` <body> class that the lg:sidebar-expanded:* variants use).
export default class extends Controller {
  static targets = ["backdrop", "drawer", "toggle"];
  static values = { open: Boolean, expanded: Boolean };

  connect() {
    this.openValue = this.readStoredState("sessionStorage", "sidebar-open");
    this.expandedValue = this.readStoredState("localStorage", "sidebar-expanded");
    // Stimulus fires the *ValueChanged callbacks for their defaults while
    // connecting, before these reads. Flag that we've restored from storage so
    // the callbacks only persist genuine changes (including expandedValue
    // written by submenu controllers through the outlet) and never clobber the
    // saved state on the next navigation.
    this.restored = true;
    this.sync();
    this.syncExpanded();
  }

  // Mobile hamburger / drawer close button. stopPropagation keeps this click
  // from reaching the window-level hide listener (mirrors Alpine's `.stop`).
  toggle(event) {
    event.stopPropagation();
    this.openValue = !this.openValue;
  }

  close() {
    this.openValue = false;
  }

  // Window click: close the drawer when the click lands outside it.
  hide(event) {
    if (this.openValue && this.hasDrawerTarget && !this.drawerTarget.contains(event.target)) {
      this.openValue = false;
    }
  }

  openValueChanged() {
    if (!this.restored) return;
    this.persistState("sessionStorage", "sidebar-open", this.openValue);
    this.sync();
  }

  sync() {
    const open = this.openValue;
    if (this.hasDrawerTarget) {
      this.drawerTarget.classList.toggle("translate-x-0", open);
      this.drawerTarget.classList.toggle("-translate-x-64", !open);
    }
    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.toggle("opacity-100", open);
      this.backdropTarget.classList.toggle("opacity-0", !open);
      this.backdropTarget.classList.toggle("pointer-events-none", !open);
    }
    this.toggleTargets.forEach((el) => el.setAttribute("aria-expanded", String(open)));
  }

  // Desktop rail expand/collapse. Submenu controllers read/write `expandedValue`
  // through a Stimulus outlet to reproduce "click a collapsed menu -> expand".
  toggleExpanded() {
    this.expandedValue = !this.expandedValue;
  }

  expandedValueChanged() {
    if (!this.restored) return;
    this.persistState("localStorage", "sidebar-expanded", this.expandedValue);
    this.syncExpanded();
  }

  syncExpanded() {
    this.element.classList.toggle("sidebar-expanded", this.expandedValue);
  }

  readStoredState(storageName, key) {
    try {
      return window[storageName].getItem(key) === "true";
    } catch {
      return false;
    }
  }

  persistState(storageName, key, value) {
    try {
      window[storageName].setItem(key, String(value));
    } catch {
      // Storage is optional; keep the drawer and rail usable for this page.
    }
  }
}
