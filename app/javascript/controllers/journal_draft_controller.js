import { Controller } from "@hotwired/stimulus"

// data-controller="journal-draft"
// Saves and restores journal drafts in localStorage under
//   forms/journal/[projectId]
export default class extends Controller {
  static values = {
    projectId: Number
  }
  static targets = ["status", "textarea", "summary", "hours", "submit"]

  connect() {
    this.form = this.element.closest("form")

    if (!this.projectIdValue || !this.hasTextareaTarget) return

    this.key = `forms/journal/${this.projectIdValue}`

    // Restore
    const restored = this.restore()
    if (restored || this.hasSavedData()) this.setSavedStatus()
    else this.hideStatus()

    // Bind events
    this._scheduleSave = this.debounce(() => this.save(), 300)
    this._onFieldInput = () => { this.setSavingStatus(); this._scheduleSave() }

    this.textareaTarget.addEventListener("input", this._onFieldInput)
    this.textareaTarget.addEventListener("change", this._onFieldInput)
    if (this.hasSummaryTarget) {
      this.summaryTarget.addEventListener("input", this._onFieldInput)
      this.summaryTarget.addEventListener("change", this._onFieldInput)
    }
    if (this.hasHoursTarget) {
      this.hoursTarget.addEventListener("input", this._onFieldInput)
      this.hoursTarget.addEventListener("change", this._onFieldInput)
    }

    // Poll for programmatic updates (e.g., image markdown inserted by editor)
    this._lastSnapshot = this.snapshot()
    this._poll = setInterval(() => {
      const now = this.snapshot()
      if (now !== this._lastSnapshot) {
        this._lastSnapshot = now
        this.setSavingStatus()
        this._scheduleSave()
      }
    }, 300)

    // Clear on submit (standard submit, Turbo success, and direct button click)
    if (this.form) {
      this._onSubmit = () => this.clear()
      this.form.addEventListener("submit", this._onSubmit)

      // Direct button click (clears immediately when user clicks Publish)
      this._submitBtnRef = this.submitButton
      if (this._submitBtnRef) {
        this._onSubmitClick = () => { this.clear(); this.afterSubmitTeardown() }
        this._submitBtnRef.addEventListener("click", this._onSubmitClick)
      }

      this._onTurboSubmitEnd = (event) => {
        if (event.target === this.form && event.detail && event.detail.success) {
          this.clear()
          this.afterSubmitTeardown()
        }
      }
      document.addEventListener("turbo:submit-end", this._onTurboSubmitEnd)
    }
  }

  disconnect() {
    if (this.hasTextareaTarget && this._onFieldInput) {
      this.textareaTarget.removeEventListener("input", this._onFieldInput)
      this.textareaTarget.removeEventListener("change", this._onFieldInput)
    }
    if (this.hasHoursTarget && this._onFieldInput) {
      this.hoursTarget.removeEventListener("input", this._onFieldInput)
      this.hoursTarget.removeEventListener("change", this._onFieldInput)
    }
    if (this.hasSummaryTarget && this._onFieldInput) {
      this.summaryTarget.removeEventListener("input", this._onFieldInput)
      this.summaryTarget.removeEventListener("change", this._onFieldInput)
    }
    if (this.form && this._onSubmit) {
      this.form.removeEventListener("submit", this._onSubmit)
    }
    if (this._submitBtnRef && this._onSubmitClick) {
      this._submitBtnRef.removeEventListener("click", this._onSubmitClick)
      this._submitBtnRef = null
    }
    if (this._onTurboSubmitEnd) {
      document.removeEventListener("turbo:submit-end", this._onTurboSubmitEnd)
    }
    if (this._poll) clearInterval(this._poll)
  }

  get submitButton() {
    return this.hasSubmitTarget ? this.submitTarget : (this.form?.querySelector('[type="submit"]') || null)
  }

  restore() {
    try {
      const raw = localStorage.getItem(this.key)
      if (!raw) return false
      const data = JSON.parse(raw)
      let restoredSomething = false
      // Only restore if current values are empty to avoid overwriting
      if (this.hasTextareaTarget && !this.textareaTarget.value && typeof data.content === "string" && data.content.trim().length > 0) {
        this.textareaTarget.value = data.content
        restoredSomething = true
      }
      if (this.hasSummaryTarget && !this.summaryTarget.value && typeof data.summary === "string" && data.summary.trim().length > 0) {
        this.summaryTarget.value = data.summary
        restoredSomething = true
      }
      if (this.hasHoursTarget && !this.hoursTarget.value && data.duration_hours != null) {
        this.hoursTarget.value = data.duration_hours
        restoredSomething = true
      }
      return restoredSomething
    } catch (_) { return false }
  }

  save() {
    try {
      const content = (this.hasTextareaTarget ? (this.textareaTarget.value || "") : "").trim()
      const summary = (this.hasSummaryTarget ? (this.summaryTarget.value || "") : "").trim()
      const hoursRaw = this.hasHoursTarget ? this.hoursTarget.value : ""
      let hours = hoursRaw === "" ? null : (parseFloat(hoursRaw) || null)
           if (hours != null) hours = Math.round(hours * 10) / 10
      
      // Only persist if we actually have something meaningful
      const hasContent = content.length > 0
           const hasSummary = summary.length > 0
      const hasHours = hours != null
      
      if (!hasContent && !hasSummary && !hasHours) {
      this.clear()
        this.hideStatus()
             return
      }
      
      const payload = {
      content,
        summary,
        duration_hours: hours,
        updatedAt: Date.now()
      }
      localStorage.setItem(this.key, JSON.stringify(payload))
      this.setSavedStatus()
    } catch (_) {}
  }

  clear() {
    try { localStorage.removeItem(this.key) } catch (_) {}
    this.hideStatus()
  }

  afterSubmitTeardown() {
    if (this._poll) clearInterval(this._poll)
    if (this.hasTextareaTarget && this._onFieldInput) {
      this.textareaTarget.removeEventListener("input", this._onFieldInput)
      this.textareaTarget.removeEventListener("change", this._onFieldInput)
    }
    if (this.hasSummaryTarget && this._onFieldInput) {
      this.summaryTarget.removeEventListener("input", this._onFieldInput)
      this.summaryTarget.removeEventListener("change", this._onFieldInput)
    }
    if (this.hasHoursTarget && this._onFieldInput) {
      this.hoursTarget.removeEventListener("input", this._onFieldInput)
      this.hoursTarget.removeEventListener("change", this._onFieldInput)
    }
  }

  hasSavedData() {
    try {
      const raw = localStorage.getItem(this.key)
      if (!raw) return false
      const data = JSON.parse(raw)
      const hasContent = typeof data.content === "string" && data.content.trim().length > 0
      const hasSummary = typeof data.summary === "string" && data.summary.trim().length > 0
      const hasHours = data.duration_hours != null
      return hasContent || hasSummary || hasHours
    } catch (_) { return false }
  }

  setSavingStatus() {
    if (!this.hasStatusTarget) return
    this.statusTarget.hidden = false
    this.statusTarget.textContent = "Saving Locally..."
  }

  setSavedStatus() {
    if (!this.hasStatusTarget) return
    this.statusTarget.hidden = false
    this.statusTarget.textContent = "Draft Saved Locally"
  }

  hideStatus() {
    if (!this.hasStatusTarget) return
    this.statusTarget.hidden = true
  }

  snapshot() {
    const content = this.hasTextareaTarget ? (this.textareaTarget.value || "") : ""
    const summary = this.hasSummaryTarget ? (this.summaryTarget.value || "") : ""
    const hoursRaw = this.hasHoursTarget ? (this.hoursTarget.value || "") : ""
    return `${content}||${summary}||${hoursRaw}`
  }

  debounce(fn, wait) {
    let t
    return (...args) => {
      clearTimeout(t)
      t = setTimeout(() => fn.apply(this, args), wait)
    }
  }
}
