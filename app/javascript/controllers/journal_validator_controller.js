import { Controller } from "@hotwired/stimulus"

// data-controller="journal-validator"
// Enforces a minimum character count (excluding image markdown), a minimum image count,
// and a positive hour count.
// Configure via data values:
//   data-journal-validator-min-chars-value="100"
//   data-journal-validator-image-required-value="true"
export default class extends Controller {
  static values = {
    minChars: { type: Number, default: 100 },
    imageRequired: { type: Boolean, default: true }
  }
  static targets = ["charCount", "imageCount", "textarea", "hours", "submit"]

  connect() {
    if (!this.hasTextareaTarget) return

    this._onInput = this.onInput.bind(this)
    this.textareaTarget.addEventListener("input", this._onInput)
    this.textareaTarget.addEventListener("change", this._onInput)
    this.textareaTarget.addEventListener("keyup", this._onInput)

    if (this.hasHoursTarget) {
      this.hoursTarget.addEventListener("input", this._onInput)
      this.hoursTarget.addEventListener("change", this._onInput)
    }

    // Fallback: poll for programmatic changes after uploads/insertions
    this._lastValue = this.textareaTarget.value
    this._poll = setInterval(() => {
      if (!this.hasTextareaTarget) return
      if (this.textareaTarget.value !== this._lastValue) {
        this._lastValue = this.textareaTarget.value
        this.onInput()
      }
    }, 300)

    // Initial compute
    this.onInput()
  }

  disconnect() {
    if (this.hasTextareaTarget && this._onInput) {
      this.textareaTarget.removeEventListener("input", this._onInput)
      this.textareaTarget.removeEventListener("change", this._onInput)
      this.textareaTarget.removeEventListener("keyup", this._onInput)
    }
    if (this.hasHoursTarget && this._onInput) {
      this.hoursTarget.removeEventListener("input", this._onInput)
      this.hoursTarget.removeEventListener("change", this._onInput)
    }
    if (this._poll) clearInterval(this._poll)
  }

  onInput() {
    const content = this.hasTextareaTarget ? (this.textareaTarget.value || "") : ""
    const imageRegex = /!\[[^\]]*\]\([^)]+\)/g

    const imageMatches = content.match(imageRegex) || []
    const withoutImages = content.replace(imageRegex, "")

    // Normalize for character count: strip leading/trailing spaces per line and remove newlines
    const normalized = withoutImages
      .split(/\r?\n/)
      .map(line => line.trim())
      .join("")

    const chars = normalized.length
    const images = imageMatches.length

    // Hours validation (> 0)
    const hoursValue = this.hasHoursTarget ? Number(this.hoursTarget.value) : NaN
    const okHours = this.hasHoursTarget ? Number.isFinite(hoursValue) && hoursValue > 0 : true

    // Update UI
    if (this.hasCharCountTarget) this.charCountTarget.textContent = `${chars}/${this.minCharsValue}`
    if (this.hasImageCountTarget) this.imageCountTarget.textContent = `${images}/1`

    // Toggle submit availability
    const okChars = chars >= this.minCharsValue
    const okImages = this.imageRequiredValue ? images >= 1 : true
    const valid = okChars && okImages && okHours

    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = !valid
    }

    // Optionally add classes to the counters
    this.toggleStateClass(this.charCountTarget, okChars)
    this.toggleStateClass(this.imageCountTarget, okImages)
  }

  toggleStateClass(el, ok) {
    if (!el) return
    el.classList.toggle("text-bp-success", ok)
  }
}
