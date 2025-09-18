import { Controller } from "@hotwired/stimulus"

// Clickable container that navigates to a URL, but ignores clicks on links/buttons
export default class extends Controller {
  static values = { url: String }

  go(event) {
    // Do not hijack real links, buttons, or explicitly ignored elements
    if (event.target.closest("a, button, [data-visit-ignore]")) return

    const url = this.urlValue
    if (!url) return

    if (window.Turbo?.visit) {
      window.Turbo.visit(url)
    } else {
      window.location.assign(url)
    }
  }
}
