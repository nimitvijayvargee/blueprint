import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "hidden", "error", "tierSelect"]
  static values = {
    tierMaxCents: Object
  }

  connect() {
    this.validateAmount()
  }

  tierChanged() {
    this.validateAmount()
  }

  formatInput(event) {
    let value = event.target.value.replace(/[^0-9.]/g, '')
    
    const parts = value.split('.')
    if (parts.length > 2) {
      value = parts[0] + '.' + parts.slice(1).join('')
    }
    
    if (parts[1] && parts[1].length > 2) {
      value = parts[0] + '.' + parts[1].substring(0, 2)
    }
    
    event.target.value = value
    this.updateCents()
    this.validateAmount()
  }

  updateCents() {
    const dollars = parseFloat(this.inputTarget.value) || 0
    const cents = Math.round(dollars * 100)
    this.hiddenTarget.value = cents
  }

  validateAmount() {
    const cents = parseInt(this.hiddenTarget.value) || 0
    const tier = this.hasTierSelectTarget ? parseInt(this.tierSelectTarget.value) : null
    
    if (!tier) {
      this.clearError()
      return
    }

    const maxCents = this.tierMaxCentsValue[tier] || 0
    const maxDollars = (maxCents / 100).toFixed(2)

    if (cents > maxCents) {
      this.showError(`Amount cannot exceed $${maxDollars} for Tier ${tier}`)
      this.inputTarget.classList.add('border-bp-danger')
      this.inputTarget.classList.remove('border-bp-muted')
    } else {
      this.clearError()
      this.inputTarget.classList.remove('border-bp-danger')
      this.inputTarget.classList.add('border-bp-muted')
    }
  }

  showError(message) {
    if (this.hasErrorTarget) {
      this.errorTarget.textContent = message
      this.errorTarget.classList.remove('hidden')
    }
  }

  clearError() {
    if (this.hasErrorTarget) {
      this.errorTarget.textContent = ''
      this.errorTarget.classList.add('hidden')
    }
  }
}
