import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["entry"]
  static values = {
    threshold: { type: Number, default: 5000 } // 5 seconds in ms
  }

  connect() {
    this.activeEntry = null
    this.viewTimer = null
    this.trackedEntries = new Set()
    this.scrollTimeout = null

    // Throttled check which entry is centered
    this.checkActiveEntry = this.throttledCheck.bind(this)
    window.addEventListener("scroll", this.checkActiveEntry, { passive: true })
    window.addEventListener("resize", this.checkActiveEntry, { passive: true })

    // Initial check
    this.throttledCheck()
  }

  disconnect() {
    window.removeEventListener("scroll", this.checkActiveEntry)
    window.removeEventListener("resize", this.checkActiveEntry)
    this.clearTimer()
    if (this.scrollTimeout) {
      clearTimeout(this.scrollTimeout)
    }
  }

  throttledCheck() {
    // Clear any pending check
    if (this.scrollTimeout) {
      clearTimeout(this.scrollTimeout)
    }

    // Wait for scrolling to settle (500ms of no scrolling)
    this.scrollTimeout = setTimeout(() => {
      this.findActiveEntry()
    }, 500)
  }

  findActiveEntry() {
    const screenCenterY = window.innerHeight / 2
    let closestEntry = null
    let closestDistance = Infinity

    this.entryTargets.forEach(entry => {
      const rect = entry.getBoundingClientRect()
      
      // Only consider entries that are at least partially visible
      if (rect.bottom < 0 || rect.top > window.innerHeight) {
        return
      }

      const entryCenterY = rect.top + rect.height / 2
      const distance = Math.abs(screenCenterY - entryCenterY)

      if (distance < closestDistance) {
        closestDistance = distance
        closestEntry = entry
      }
    })

    // If the active entry changed, reset timer
    if (closestEntry !== this.activeEntry) {
      this.clearTimer()
      this.activeEntry = closestEntry

      if (this.activeEntry && !this.hasTrackedEntry(this.activeEntry)) {
        // Start timer for the new active entry
        this.startTimer(this.activeEntry)
      }
    }
  }

  startTimer(entry) {
    this.viewTimer = setTimeout(() => {
      this.trackView(entry)
    }, this.thresholdValue)
  }

  clearTimer() {
    if (this.viewTimer) {
      clearTimeout(this.viewTimer)
      this.viewTimer = null
    }
  }

  trackView(entry) {
    const link = entry.querySelector('a[data-entry-link]')
    if (!link) return

    const url = link.getAttribute('href')
    if (!url || this.hasTrackedEntry(entry)) return

    // Mark as tracked to prevent duplicate tracking
    this.markAsTracked(entry)

    // Make GET request to track the view
    fetch(url, {
      method: 'GET',
      headers: {
        'Accept': 'text/vnd.turbo-stream.html',
        'X-Requested-With': 'XMLHttpRequest'
      }
    }).catch(error => {
      console.error('Failed to track entry view:', error)
    })
  }

  hasTrackedEntry(entry) {
    return this.trackedEntries.has(entry.dataset.entryId)
  }

  markAsTracked(entry) {
    this.trackedEntries.add(entry.dataset.entryId)
  }
}
