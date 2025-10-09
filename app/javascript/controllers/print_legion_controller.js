import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["secondQuestion", "hidden"]

  connect() {
    this.update()
  }

  update() {
    const has3dRadio = this.element.querySelector('input[name="project[has_3d_print]"]:checked')
    const has3d = has3dRadio?.value === "yes"
    
    this.secondQuestionTarget.classList.toggle("hidden", !has3d)
    
    const needsHelpRadio = this.element.querySelector('input[name="project[needs_3d_print_help]"]:checked')
    const needsHelp = needsHelpRadio?.value === "yes"
    
    this.hiddenTarget.value = (has3d && needsHelp) ? "true" : "false"
  }
}
