import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["item"];

  click(event) {
    let eventId = event.path[3].id
    this.itemTargets.forEach((element) => {
      if (element.id == eventId) {
        element.classList.add('transform', 'opacity-0', 'transition', 'duration-1000');
        setTimeout(() => element.remove(), 800)
      }
    })
  }
}
