import { Controller } from "@hotwired/stimulus"

// Toggles the `dark` class on <html> and persists the explicit choice to
// localStorage. The initial (pre-paint) state is applied by the inline FOUC
// script in shared/_head, which prefers the stored value and otherwise falls
// back to the OS `prefers-color-scheme`. On connect we only mirror that state
// onto the button's aria-pressed; we never write to storage here so a visitor
// who has not chosen a theme keeps following their system preference.
export default class extends Controller {
  static STORAGE_KEY = "theme"

  connect() {
    this.sync()
  }

  toggle() {
    const dark = !this.isDark()
    document.documentElement.classList.toggle("dark", dark)
    this.persist(dark)
    this.sync()
  }

  isDark() {
    return document.documentElement.classList.contains("dark")
  }

  persist(dark) {
    try {
      localStorage.setItem(this.constructor.STORAGE_KEY, dark ? "dark" : "light")
    } catch (error) {
      // Storage may be unavailable (private mode / disabled). The toggle still
      // works for the current page; we just can't remember the choice.
    }
  }

  // Keep the toggle button's pressed state in sync for assistive technology.
  sync() {
    this.element.setAttribute("aria-pressed", String(this.isDark()))
  }
}
