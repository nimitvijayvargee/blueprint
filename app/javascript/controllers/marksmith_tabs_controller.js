import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.syncActive()
  }

  write() {
    this.clickHidden('write')
    this.syncLater()
  }

  preview() {
    this.clickHidden('preview')
    this.syncLater()
  }

  syncLater() {
    requestAnimationFrame(() => this.syncActive())
  }

  syncActive() {
    const root = this.element.closest('.marksmith-editor-wrapper')
    if (!root) return
    const previewTab = root.querySelector('.marksmith-preview-tab')
    const isPreviewActive = previewTab && previewTab.classList.contains('active')

    const writeBtn = this.element.querySelector('[data-role="write"]')
    const previewBtn = this.element.querySelector('[data-role="preview"]')
    if (!writeBtn || !previewBtn) return

    if (isPreviewActive) {
      writeBtn.classList.remove('active')
      previewBtn.classList.add('active')
    } else {
      previewBtn.classList.remove('active')
      writeBtn.classList.add('active')
    }
  }

  clickHidden(which) {
    const root = this.element.closest('.marksmith-editor-wrapper')
    if (!root) return
    const selector = which === 'write' ? '.marksmith-write-tab' : '.marksmith-preview-tab'
    const btn = root.querySelector(selector)
    if (btn) btn.click()
  }
}
