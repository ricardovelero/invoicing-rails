import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ["modal"];

  connect() {
    console.log("Modal stimulus loaded...");
  }

  open() {
    console.log("Open");
    this.modalTarget.classList.remove("opacity-0", "pointer-events-none");
  }

  close(event) {
    console.log("Close");
    event.stopPropagation();
    this.modalTarget.classList.add("opacity-0", "pointer-events-none");
  }
}
