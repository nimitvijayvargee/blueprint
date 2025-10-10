import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  go(event) {
    const ref = document.referrer
    if (ref && this.sameOrigin(ref) && this.fromListing(ref)) {
      event.preventDefault()
      // Browser back => Turbo history restoration => scroll is restored
      window.history.back()
    }
    // else: normal navigation to href (fallback)
  }

  sameOrigin(url) {
    try {
      const u = new URL(url)
      return u.host === window.location.host && u.protocol === window.location.protocol
    } catch {
      return false
    }
  }

  fromListing(url) {
    try {
      const p = new URL(url).pathname
      return /^\/(explore|projects)\b/.test(p)
    } catch {
      return false
    }
  }
}
