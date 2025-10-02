import { Controller } from "@hotwired/stimulus"

// Redirects to the login page with the entered email as a URL param
export default class extends Controller {
  static targets = ["input"]
  static values = { loginUrl: String }

  go() {
    const email = (this.inputTarget?.value || "").trim()
    const url = new URL(this.loginUrlValue, window.location.origin)
    if (email.length > 0) {
      url.searchParams.set("email", email)
    }
    window.location.assign(url.toString())
  }
  
  checkEnter(event) {
    if (event.key === "Enter") {
      this.go()
    }
  }
}
