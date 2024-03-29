import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "qty",
    "price",
    "iva",
    "total",
    "subtotal",
    "taxtotal",
    "grandtotal",
    "hiddensubtotal",
    "hiddentaxtotal",
    "hiddengrandtotal",
  ];

  connect() {
    const langAttribute = document.documentElement.lang;
    this.currency = langAttribute === "es" ? "EUR" : "USD";
    this.format = langAttribute === "es" ? "es-ES" : "en-US";
  }

  recalculate(event) {
    const formatter = new Intl.NumberFormat(this.format, {
      style: "currency",
      currency: this.currency,
    });

    let itemTotal = 0;
    let subTotal = 0;
    let grandTotal = 0;
    let ivaArray = [];
    let qtysArray = [];
    let pricesArray = [];

    this.ivaTargets.forEach((iva, index) => {
      ivaArray[index] = iva.value.trim() * 1;
    });

    this.qtyTargets.forEach((qty, index) => {
      qtysArray[index] = qty.value;
    });

    this.priceTargets.forEach((price, index) => {
      pricesArray[index] = price.value;
    });

    this.totalTargets.forEach((element, index) => {
      itemTotal =
        pricesArray[index] * (1 + ivaArray[index] / 100) * qtysArray[index];

      element.value = itemTotal.toFixed(2);

      grandTotal += itemTotal;

      subTotal += itemTotal / (1 + ivaArray[index] / 100);
    });

    this.subtotalTarget.textContent = formatter.format(subTotal);
    this.taxtotalTarget.textContent = formatter.format(grandTotal - subTotal);
    this.grandtotalTarget.textContent = formatter.format(grandTotal);

    this.hiddensubtotalTarget.value = subTotal;
    this.hiddentaxtotalTarget.value = grandTotal - subTotal;
    this.hiddengrandtotalTarget.value = grandTotal;
  }

  convertNum(element) {
    return (
      element
        .replace("$", "")
        .replace("€", "")
        .replace("&euro", "")
        .replace(".", "")
        .replace(",", ".")
        .trim() * 1
    );
  }
}
