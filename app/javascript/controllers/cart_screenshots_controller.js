import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { needsFunding: Boolean, hasExisting: Boolean }
  static targets = ["input", "error", "previews"]

  connect() {
    this.updatePreviews()
  }

  filesChanged() {
    this.errorTarget.classList.add("hidden")
    this.errorTarget.textContent = ""
    this.updatePreviews()
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

  handleNext(event) {
    event.preventDefault()
    
    if (this.needsFundingValue && !this.hasAtLeastOneImage()) {
      this.errorTarget.textContent = "Please upload at least one image."
      this.errorTarget.classList.remove("hidden")
      return
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
}
