import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "submitButton"]

  connect() {
    this.validate()
  }

  validate() {
    if (!this.hasSubmitButtonTarget) return
    
    const allChecked = this.checkboxTargets.every(checkbox => checkbox.checked)
    this.submitButtonTarget.disabled = !allChecked
  }

  handlePrev(event) {
    event.preventDefault()
    
    const needsFundingRadio = document.querySelector('input[name="project[needs_funding]"]:checked')
    const needsFunding = needsFundingRadio ? needsFundingRadio.value === "true" : true
    
    const paginateController = this.application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller*="paginate"]'),
      "paginate"
    )
    
    if (paginateController) {
      if (needsFunding) {
        paginateController.prev()
      } else {
        paginateController.prevJump()
      }
    }
  }
}
