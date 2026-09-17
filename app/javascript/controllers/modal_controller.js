import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="modal"
//
// The dialog opens when its turbo-frame finishes loading a form
// (turbo:frame-load) and closes on form submit (turbo:submit-end), Escape, the
// Cancel button (data-action="modal#close"), or a click on the backdrop.
//
// "Click outside to dismiss" used to be an Alpine `x-on:click.away` on the
// dialog that dispatched a global `invokeStimulusClose` CustomEvent picked up
// by a window listener here. It is now a plain click action on the overlay: the
// overlay is `pointer-events-none` while closed, so the handler only runs when
// the modal is open, and it ignores clicks that land inside the dialog.
export default class extends Controller {
  static targets = ["modal", "content"];

  open() {
    this.modalTarget.classList.remove("opacity-0", "pointer-events-none");
  }

  close(event) {
    event.stopPropagation();
    this.modalTarget.classList.add("opacity-0", "pointer-events-none");
  }

  // Backdrop click: dismiss unless the click originated inside the dialog.
  closeOnClickOutside(event) {
    if (this.hasContentTarget && !this.contentTarget.contains(event.target)) {
      this.close(event);
    }
  }
}
