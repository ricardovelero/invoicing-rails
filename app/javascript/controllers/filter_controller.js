import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="invoice-filter"
export default class extends Controller {
  static targets = ["statusValue"];

  connect() {
    console.log("Loaded");
  }

  submitForm(event) {
    const value = event.target.dataset.value;
    this.statusValueTarget.value = value;
    this.element.submit();
  }
}
