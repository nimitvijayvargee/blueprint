import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "otherField", "otherInput", "nextButton"]

  connect() {
    this.toggle()
    this.validate()
  }

  toggle() {
    const selected = this.selectTarget.value
    if (selected === "other") {
      this.otherFieldTarget.classList.remove("hidden")
    } else {
      this.otherFieldTarget.classList.add("hidden")
    }
    this.validate()
  }

  validate() {
    if (!this.hasNextButtonTarget) return
    
    const selected = this.selectTarget.value
    if (selected === "other") {
      const otherValue = this.otherInputTarget.value.trim()
      this.nextButtonTarget.disabled = otherValue === ""
    } else {
      this.nextButtonTarget.disabled = false
    }
  }

  handleNext(event) {
    event.preventDefault()
    
    const needsFundingRadio = document.querySelector('input[name="project[needs_funding]"]:checked')
    const needsFunding = needsFundingRadio ? needsFundingRadio.value === "true" : true
    
    const paginateController = this.application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller*="paginate"]'),
      "paginate"
    )
    
    if (paginateController) {
      if (needsFunding) {
        paginateController.next()
      } else {
        paginateController.nextJump()
      }
    }
  }
}
