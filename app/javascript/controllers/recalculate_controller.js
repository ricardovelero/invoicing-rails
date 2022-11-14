import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["total", "price", "tax", "subtotal", "taxtotal", "grandtotal", "theid"];

  initialize() {
    let theids = []
    this.theidTargets.forEach((element, index) => {
      theids[index] = element.id.match(/\d/g).join("")
    })
    this.totalTargets.forEach((element, index) => {
      element.id = theids[index]
    })
    this.priceTargets.forEach((element, index) => {
      element.id = theids[index]
    })
    this.taxTargets.forEach((element, index) => {
      element.id = theids[index]
    })
  }

  recalculate(event) {
    const formatter = new Intl.NumberFormat(undefined, {
      style: 'currency',
      currency: 'EUR',
    });

    let eventId = event.target.id.match(/\d/g).join("")
    let itemPrice, itemTax = ""
    let itemTotal, sum = 0

    this.totalTargets.forEach((element) => {
      if (element.id == eventId) {
        this.priceTargets.forEach((element) => {
          if (element.id == eventId) {
            itemPrice = this.convertNum(element.textContent)
          }
        })
        this.taxTargets.forEach((element) => {
          if (element.id == eventId) {
            itemTax = this.convertNum(element.textContent)
          }
        })
        itemTotal = itemPrice * (1 + itemTax/100) * event.target.value

        element.textContent = formatter.format(itemTotal)
      }
      sum += this.convertNum(element.textContent)
    })
    this.grandtotalTarget.textContent = formatter.format(sum)

  }

  convertNum(element) {
    return element.replace('€', '').replace('&euro', '').replace(',', '.').trim() * 1
  }

}
