import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["quantity", "unitPrice", "vatRate", "subtotal", "total"]

  connect() {
    this.recalculate()
  }

  recalculate() {
    const quantity = Number(this.quantityTarget.value)
    const unitPrice = Number(this.unitPriceTarget.value)
    const vatRate = Number(this.vatRateTarget.value)

    if (!quantity || Number.isNaN(unitPrice) || Number.isNaN(vatRate)) {
      this.subtotalTarget.textContent = "Total HT"
      this.totalTarget.textContent = "Total TTC"
      return
    }

    const unitPriceCents = Math.round(unitPrice * 100)
    const subtotalCents = quantity * unitPriceCents
    const totalCents = Math.round(subtotalCents + (subtotalCents * vatRate) / 100)

    this.subtotalTarget.textContent = this.formatCents(subtotalCents)
    this.totalTarget.textContent = this.formatCents(totalCents)
  }

  formatCents(cents) {
    return new Intl.NumberFormat("en", {
      style: "currency",
      currency: "EUR",
      minimumFractionDigits: 2
    }).format(cents / 100)
  }
}
