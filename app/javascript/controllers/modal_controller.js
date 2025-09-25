import { Controller } from "@hotwired/stimulus"

// Example wiring on the modal element:
//   data-controller="modal"
//   data-action="modal:show-example@window->modal#show modal:hide-example@window->modal#hide"
// Example wiring on the trigger button:
//   data-controller="modal"
//   data-modal-target-id-value="example"
//   data-action="click->modal#show"
export default class extends Controller {
  static targets = ["panel", "overlay", "initialFocus", "step"]

  static values = {
    open: { type: Boolean, default: false },
    closeOnEscape: { type: Boolean, default: true },
    closeOnBackdrop: { type: Boolean, default: true },
    disableScroll: { type: Boolean, default: true },
    targetId: String,
    startingStep: { type: Number, default: 0 }
  }

  connect() {
    if (this.hasTargetIdValue) return

    this._currentStep = this.startingStepValue
    this._onKeydown = this._onKeydown.bind(this)
    this._onBackdropClick = this._onBackdropClick.bind(this)

    if (this.hasOverlayTarget) this.overlayTarget.addEventListener("click", this._onBackdropClick)

    // Initialize step visibility
    this._updateSteps()

    this._applyOpenState(this.openValue)
  }

  disconnect() {
    if (this.hasTargetIdValue) return

    if (this.hasOverlayTarget) this.overlayTarget.removeEventListener("click", this._onBackdropClick)
    this._unlockScroll()
  }

  // Public actions
  show() {
    if (this.hasTargetIdValue) {
      this.dispatch(`show-${this.targetIdValue}`, { target: window })
      return
    }

    if (this.openValue) return
    this.openValue = true
    this._currentStep = this.startingStepValue
    this._updateSteps()
    this._applyOpenState(true)
  }

  hide() {
    if (this.hasTargetIdValue) {
      this.dispatch(`hide-${this.targetIdValue}`, { target: window })
      return
    }

    if (!this.openValue) return
    this.openValue = false
    this._applyOpenState(false)
  }

  toggle() {
    if (this.hasTargetIdValue) {
      this.dispatch(`toggle-${this.targetIdValue}`, { target: window })
      return
    }

    this.openValue ? this.hide() : this.show()
  }

  next() {
    if (this.hasTargetIdValue) {
      this.dispatch(`next-${this.targetIdValue}`, { target: window })
    }
    
    this._currentStep = Math.min(this._currentStep + 1, this.stepTargets.length - 1)
    this._updateSteps()
  }

  previous() {
    if (this.hasTargetIdValue) {
      this.dispatch(`previous-${this.targetIdValue}`, { target: window })
    }
    
    this._currentStep = Math.max(this._currentStep - 1, 0)
    this._updateSteps()
  }

  // Internal
  _applyOpenState(open) {
    this.element.setAttribute("role", "dialog")
    this.element.setAttribute("aria-modal", "true")
    this.element.setAttribute("aria-hidden", String(!open))

    if (open) {
      this.element.hidden = false
      this.element.classList.add("is-open")
      this.element.classList.remove("hidden")
      document.addEventListener("keydown", this._onKeydown)
      if (this.disableScrollValue) this._lockScroll()
      this._focusInitial()
    } else {
      this.element.classList.remove("is-open")
      this.element.classList.add("hidden")
      this.element.hidden = true
      document.removeEventListener("keydown", this._onKeydown)
      this._unlockScroll()
    }
  }

  _onKeydown(e) {
    if (e.key === "Escape" && this.closeOnEscapeValue) {
      e.preventDefault()
      this.hide()
    }
  }

  _onBackdropClick(e) {
    if (!this.closeOnBackdropValue) return
    if (e.target === this.overlayTarget) this.hide()
  }

  _focusInitial() {
    if (this.hasInitialFocusTarget) {
      this.initialFocusTarget.focus({ preventScroll: true })
      return
    }
    const root = this.hasPanelTarget ? this.panelTarget : this.element
    const focusable = root.querySelector(
      'a[href], button:not([disabled]), textarea, input, select, [tabindex]:not([tabindex="-1"])'
    )
    if (focusable) focusable.focus({ preventScroll: true })
  }

  _lockScroll() {
    if (this._scrollLocked) return
    this._scrollLocked = true
    // this._prevBodyOverflow = document.body.style.overflow
    // document.body.style.overflow = "hidden"
  }

  _unlockScroll() {
    if (!this._scrollLocked) return
    // document.body.style.overflow = this._prevBodyOverflow || ""
    this._scrollLocked = false
  }

  _updateSteps() {
    if (!this.hasStepTarget && this.stepTargets.length === 0) return
    this.stepTargets.forEach((el, idx) => {
      const active = idx === this._currentStep
      el.hidden = !active
      el.setAttribute("aria-hidden", String(!active))
      if (active) {
        el.classList.remove("hidden")
      } else {
        el.classList.add("hidden")
      }
    })
  }
}
