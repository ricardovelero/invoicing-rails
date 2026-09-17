import { Dropdown } from "tailwindcss-stimulus-components";

// Thin subclass of the library Dropdown controller.
//
// As of v6 the component closes on outside-click and on Escape natively via
// hide() (closeOnEscape/closeOnClickOutside values) and exposes close(), so the
// previous Escape workaround is no longer needed. The only reason left to
// extend it is the user-menu chevron rotation, which the library gives no
// state hook for.
export default class extends Dropdown {
  static targets = ["chevron"];

  openValueChanged() {
    super.openValueChanged();
    if (this.hasChevronTarget) {
      this.chevronTarget.classList.toggle("rotate-180", this.openValue);
    }
  }
}
