import { Controller } from "@hotwired/stimulus"

// data-controller="journal-validator"
// Enforces a minimum character count (excluding image markdown) and a minimum image count.
// Configure via data values:
//   data-journal-validator-min-chars-value="100"
//   data-journal-validator-image-required-value="true"
export default class extends Controller {
  static values = {
    minChars: { type: Number, default: 100 },
    imageRequired: { type: Boolean, default: true }
  }
  static targets = ["charCount", "imageCount"]

  connect() {
    this.textarea = this.element.querySelector(".marksmith-textarea")
    this.submitButton = this.element.closest("form")?.querySelector('[type="submit"]')

    if (!this.textarea) return

    this._onInput = this.onInput.bind(this)
    this.textarea.addEventListener("input", this._onInput)
    this.textarea.addEventListener("change", this._onInput)
    this.textarea.addEventListener("keyup", this._onInput)

    // Fallback: poll for programmatic changes after uploads/insertions
    this._lastValue = this.textarea.value
    this._poll = setInterval(() => {
      if (!this.textarea) return
      if (this.textarea.value !== this._lastValue) {
        this._lastValue = this.textarea.value
        this.onInput()
      }
    }, 300)

    // Initial compute
    this.onInput()
  }

  disconnect() {
    if (this.textarea && this._onInput) {
      this.textarea.removeEventListener("input", this._onInput)
      this.textarea.removeEventListener("change", this._onInput)
      this.textarea.removeEventListener("keyup", this._onInput)
    }
    if (this._poll) clearInterval(this._poll)
  }

  onInput() {
    const content = this.textarea?.value || ""
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

    // Update UI
    if (this.hasCharCountTarget) this.charCountTarget.textContent = `${chars}/${this.minCharsValue}`
    if (this.hasImageCountTarget) this.imageCountTarget.textContent = `${images}/1`

    // Toggle submit availability
    const okChars = chars >= this.minCharsValue
    const okImages = this.imageRequiredValue ? images >= 1 : true
    const valid = okChars && okImages

    if (this.submitButton) {
      this.submitButton.disabled = !valid
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
