import { Controller } from "@hotwired/stimulus"

// Usage:
// <div data-controller="paginate">
//   <div data-paginate-target="page">Page 1</div>
//   <div data-paginate-target="page" class="hidden">Page 2</div>
//   ...
//   <button data-action="click->paginate#prev">Prev</button>
//   <button data-action="click->paginate#next">Next</button>
//   <button data-action="click->paginate#jumpTo" data-paginate-index-param="2">Go to 3</button>
// </div>
export default class extends Controller {
  static targets = ["page"]

  static values = {
    index: { type: Number, default: 0 }
  }

  connect() {
    this._clampIndex()
    this._updatePages()
  }

  // Navigation
  next() {
    if (this.pageTargets.length === 0) return
    this.indexValue = Math.min(this.indexValue + 1, this.pageTargets.length - 1)
    this._updatePages()
  }

  nextJump() {
    if (this.pageTargets.length === 0) return
    this.indexValue = Math.min(this.indexValue + 2, this.pageTargets.length - 1)
    this._updatePages()
  }

  prev() {
    if (this.pageTargets.length === 0) return
    this.indexValue = Math.max(this.indexValue - 1, 0)
    this._updatePages()
  }

  prevJump() {
    if (this.pageTargets.length === 0) return
    this.indexValue = Math.max(this.indexValue - 2, 0)
    this._updatePages()
  }

  // Accepts Stimulus action params: data-paginate-index-param="<number>"
  jumpTo({ params } = {}) {
    if (this.pageTargets.length === 0) return
    const raw = params?.index
    const i = Number(raw)
    if (!Number.isFinite(i)) return
    this.indexValue = Math.max(0, Math.min(i, this.pageTargets.length - 1))
    this._updatePages()
  }

  // Internal
  _clampIndex() {
    if (this.pageTargets.length === 0) {
      this.indexValue = 0
      return
    }
    this.indexValue = Math.max(0, Math.min(this.indexValue, this.pageTargets.length - 1))
  }

  _updatePages() {
    if (!this.hasPageTarget && this.pageTargets.length === 0) return

    this.pageTargets.forEach((el, idx) => {
      const active = idx === this.indexValue
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
