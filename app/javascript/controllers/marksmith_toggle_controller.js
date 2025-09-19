import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.syncActive()
  }

  toggle(event) {
    const root = event.currentTarget.closest('.marksmith-editor-wrapper')
    if (!root) return

    const previewTab = root.querySelector('.marksmith-preview-tab')
    const writeTab = root.querySelector('.marksmith-write-tab')
    if (!previewTab || !writeTab) return

    if (previewTab.classList.contains('active')) {
      writeTab.click()
    } else {
      previewTab.click()
    }

    // After switching, update the visible button state
    requestAnimationFrame(() => this.syncActive())
  }

  syncActive() {
    const root = this.element.closest('.marksmith-editor-wrapper')
    if (!root) return
    const previewTab = root.querySelector('.marksmith-preview-tab')
    if (!previewTab) return

    if (previewTab.classList.contains('active')) {
      this.element.classList.add('active')
    } else {
      this.element.classList.remove('active')
    }
  }
}

