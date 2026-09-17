import { Controller } from "@hotwired/stimulus";

// "Select all" table behavior shared by the invoices, items and clients index
// pages. Migrated from the Alpine `handleSelect` component that each of those
// pages registered inline via an `alpine:init` <script>.
//
// The controller lives on the table wrapper. The bulk-action bar
// (.table-items-action) and its count (.table-items-count) render OUTSIDE that
// wrapper - and on the invoices/items pages, outside the #invoices / #items
// turbo-frame too - so they cannot be Stimulus targets here. As in the original
// Alpine code they are looked up on the document; each is a page singleton.
export default class extends Controller {
  static targets = ["parent", "item"];

  // Header checkbox: mirror its new state onto every row, then refresh the bar.
  // Programmatic `.checked =` does not fire change events, so rows do not
  // re-enter uncheckParent (same as the original Alpine behavior).
  toggleAll(event) {
    const checked = event.currentTarget.checked;
    this.itemTargets.forEach((item) => {
      item.checked = checked;
    });
    this.refresh();
  }

  // A row changed, so "select all" no longer holds: clear the header checkbox.
  uncheckParent() {
    if (this.hasParentTarget) this.parentTarget.checked = false;
    this.refresh();
  }

  // Show/hide the bulk-action bar and update the selected-count label.
  refresh() {
    const bar = document.querySelector(".table-items-action");
    if (!bar) return;
    const count = this.itemTargets.filter((item) => item.checked).length;
    const label = document.querySelector(".table-items-count");
    if (label) label.textContent = count;
    bar.classList.toggle("hidden", count === 0);
  }
}
