import { Dropdown } from "tailwindcss-stimulus-components";

// Extends the shared Dropdown component from tailwindcss-stimulus-components.
//
// The vendored v3.0.4 `hide(event)` only closes the menu when the click lands
// outside the controller element, so it can't be used for Escape-to-close while
// focus is still inside the menu. `close()` dismisses unconditionally and is
// wired to `keydown.esc@window` and to in-menu item clicks.
export default class extends Dropdown {
  close() {
    this.openValue = false;
  }
}
