import { Controller } from "@hotwired/stimulus"
import { csrfHeader } from "helpers/csrf"

// data-controller="ship-bom"
// data-ship-bom-project-id-value
// Targets: box
export default class extends Controller {
  static targets = ["box", "submit"]
  static values = {
    projectId: Number,
    url: { type: String, default: "/projects/check_bom" },
    baseOk: { type: Boolean, default: false },
  }

  connect() {
    this._bomState = "pending"
    this.updateDisabled()
    this.check()
  }

  async check() {
    try {
      const res = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          ...csrfHeader(),
        },
        body: JSON.stringify({ project_id: this.projectIdValue }),
      })

      if (!res.ok) {
        this.setDanger()
        return
      }

      const data = await res.json()
      if (data.ok && data.exists === true) {
        this.setSuccess()
      } else if (data.ok && data.exists === false) {
        this.setDanger()
      } else {
        this.setDanger()
      }
    } catch (e) {
      this.setDanger()
    }
  }

  setSuccess() {
    if (this.hasBoxTarget) {
      const el = this.boxTarget
      el.classList.remove(
        "border-bp-muted",
        "bg-bp-danger",
        "border-bp-danger",
        "border-bp-warning",
        "border-dashed",
        "animate-spin",
        "rounded-full"
      )
      el.classList.add("bg-bp-success", "border-bp-success")
    }
    this._bomState = "ok"
    this.updateDisabled()
  }

  setDanger() {
    if (this.hasBoxTarget) {
      const el = this.boxTarget
      el.classList.remove(
        "border-bp-muted",
        "bg-bp-success",
        "border-bp-success",
        "border-bp-warning",
        "border-dashed",
        "animate-spin",
        "rounded-full"
      )
      el.classList.add("bg-bp-danger", "border-bp-danger")
    }
    this._bomState = "fail"
    this.updateDisabled()
  }

  updateDisabled() {
    if (!this.hasSubmitTarget) return
    const bomOk = this._bomState === "ok"
    const allOk = !!this.baseOkValue && bomOk
    this.submitTarget.disabled = !allOk
  }
}
