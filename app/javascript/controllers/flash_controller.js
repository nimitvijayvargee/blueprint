import { Controller } from "@hotwired/stimulus"

// Handles auto-dismiss and manual dismissal of flash notices
export default class extends Controller {
  static values = {
    dismissAfter: { type: Number, default: 5000 }
  }

  connect() {
    this._dismiss = this.dismiss.bind(this)
    if (this.dismissAfterValue > 0) {
      this.timeout = setTimeout(this._dismiss, this.dismissAfterValue)
    }
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
  }

  dismiss() {
    if (this.dismissing) return
    this.dismissing = true

    // Ensure Tailwind's cascade doesn't keep opacity-100 applied
    this.element.classList.remove("opacity-100")
    // Force reflow so transition reliably runs when toggling classes
    // eslint-disable-next-line no-unused-expressions
    this.element.offsetHeight
    this.element.classList.add("opacity-0")

    const remove = () => {
      try { this.element.remove() } catch (_) {}
    }

    // Prefer transitionend to sync with Tailwind duration classes
    this.element.addEventListener("transitionend", (e) => {
      if (e.propertyName === "opacity") remove()
    }, { once: true })

    // Fallback in case transitionend doesn't fire
    setTimeout(remove, 600)
  }
}
