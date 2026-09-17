import { Dropdown } from "tailwindcss-stimulus-components";

// Thin subclass of the library Dropdown controller.
//
// As of v6 the component closes on outside-click and on Escape natively via
// hide() (closeOnEscape/closeOnClickOutside values) and exposes close(), so the
// previous Escape workaround is no longer needed. We still extend it for two
// things the library gives no hook for: the user-menu chevron rotation, and
// mirroring the open state onto the trigger's aria-expanded (the library never
// touches ARIA, and Alpine used to bind :aria-expanded="open").
export default class extends Dropdown {
  static targets = ["chevron"];

  openValueChanged() {
    super.openValueChanged();
    if (this.hasChevronTarget) {
      this.chevronTarget.classList.toggle("rotate-180", this.openValue);
    }
    // Runs on connect too (open defaults to false), seeding aria-expanded.
    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-expanded", String(this.openValue));
    }
  }
}
