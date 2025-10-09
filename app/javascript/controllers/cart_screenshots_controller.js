import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { needsFunding: Boolean, hasExisting: Boolean }
  static targets = ["input", "error", "previews", "nextButton"]

  connect() {
    this.updatePreviews()
    this.updateButtonState()
  }

  filesChanged() {
    this.clearError()
    this.updatePreviews()
    // Update hasExisting value when files are selected
    if (this.inputTarget.files && this.inputTarget.files.length > 0) {
      this.hasExistingValue = true
    }
    this.updateButtonState()
  }

  updatePreviews() {
    this.previewsTarget.innerHTML = ""
    
    const files = this.inputTarget.files || []
    Array.from(files).forEach(file => {
      if (!file.type.startsWith("image/")) return
      
      const img = document.createElement("img")
      img.className = "rounded border border-bp-muted/40 object-cover w-full h-32"
      img.src = URL.createObjectURL(file)
      this.previewsTarget.appendChild(img)
    })
  }

  updateButtonState() {
    if (!this.hasNextButtonTarget) return
    
    if (this.needsFundingValue && !this.hasAtLeastOneImage()) {
      this.nextButtonTarget.disabled = true
      this.nextButtonTarget.classList.add("opacity-50", "cursor-not-allowed")
    } else {
      this.nextButtonTarget.disabled = false
      this.nextButtonTarget.classList.remove("opacity-50", "cursor-not-allowed")
    }
  }

  handleNext(event) {
    if (this.needsFundingValue && !this.hasAtLeastOneImage()) {
      event.preventDefault()
      event.stopPropagation()
      return false
    }
    
    // Find and call paginate controller's next method
    const paginateController = this.application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller*="paginate"]'),
      "paginate"
    )
    
    if (paginateController) {
      paginateController.next()
    }
  }

  hasAtLeastOneImage() {
    return this.hasExistingValue || (this.inputTarget.files && this.inputTarget.files.length > 0)
  }

  showError(message) {
    this.errorTarget.textContent = message
    this.errorTarget.classList.remove("hidden")
  }

  clearError() {
    this.errorTarget.textContent = ""
    this.errorTarget.classList.add("hidden")
  }
}
