import { Controller } from "@hotwired/stimulus";

// Sidebar submenu disclosure, migrated from the per-<li> Alpine x-data. Each
// submenu persists its own open state in sessionStorage and coordinates with
// the shell `sidebar` controller through an outlet: clicking a menu while the
// desktop rail is collapsed expands the rail instead of opening the submenu,
// matching the old `sidebarExpanded ? open = !open : sidebarExpanded = true`.
export default class extends Controller {
  static targets = ["list", "chevron", "icon"];
  static outlets = ["sidebar"];
  static values = { open: Boolean, active: Boolean, key: String };

  connect() {
    try {
      this.openValue = sessionStorage.getItem(this.keyValue) === "true";
    } catch {
      this.openValue = false;
    }
    // Stimulus fires openValueChanged for the value's default while connecting,
    // before this read. Flag that we've restored from storage so the callback
    // only persists genuine changes and never clobbers the saved state on the
    // next navigation.
    this.restored = true;
    this.sync();
  }

  toggle(event) {
    event.preventDefault();
    if (this.sidebarOutlet.expandedValue) {
      this.openValue = !this.openValue;
    } else {
      this.sidebarOutlet.expandedValue = true;
    }
  }

  // Window click: close this submenu when the click lands outside of it.
  hide(event) {
    if (this.openValue && !this.element.contains(event.target)) {
      this.openValue = false;
    }
  }

  openValueChanged() {
    if (!this.restored) return;
    try {
      sessionStorage.setItem(this.keyValue, this.openValue);
    } catch {
      // The submenu still opens when session storage is unavailable.
    }
    this.sync();
  }

  sync() {
    const open = this.openValue;
    if (this.hasListTarget) {
      this.listTarget.classList.toggle("!block", open);
      this.listTarget.classList.toggle("hidden", !open);
    }
    if (this.hasChevronTarget) {
      this.chevronTarget.classList.toggle("rotate-180", open);
      this.chevronTarget.classList.toggle("rotate-0", !open);
    }
    // Icons highlight when the submenu is open OR the current page matches.
    const highlighted = open || this.activeValue;
    this.iconTargets.forEach((icon) => {
      const on = icon.dataset.activeClass;
      const off = icon.dataset.inactiveClass;
      if (on) icon.classList.toggle(on, highlighted);
      if (off) icon.classList.toggle(off, !highlighted);
    });
  }
}
