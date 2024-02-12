import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ["modal"];

  connect() {
    window.addEventListener("invokeStimulusClose", (event) => {
      this.close(event);
    });
  }

  open() {
    this.modalTarget.classList.remove("opacity-0", "pointer-events-none");
  }

  close(event) {
    event.stopPropagation();
    this.modalTarget.classList.add("opacity-0", "pointer-events-none");
  }
}
