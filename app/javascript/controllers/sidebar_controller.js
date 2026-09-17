import { Controller } from "@hotwired/stimulus";

// App-shell sidebar state, migrated off the Alpine `x-data` that used to live
// on <body>. It is registered on <body> so the navbar hamburger and the sidebar
// drawer/backdrop (rendered from separate partials) share one controller scope.
//
// Currently owns the mobile drawer (`open`, persisted in sessionStorage). The
// desktop `sidebar-expanded` rail is still handled by Alpine until Phase 4b.
export default class extends Controller {
  static targets = ["backdrop", "drawer", "toggle"];
  static values = { open: Boolean };

  connect() {
    this.openValue = sessionStorage.getItem("sidebar-open") === "true";
    this.sync();
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
    sessionStorage.setItem("sidebar-open", this.openValue);
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
}
