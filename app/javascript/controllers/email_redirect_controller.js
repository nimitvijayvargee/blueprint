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
    this.track(email).then(() => {
      window.location.assign(url.toString())
    })
  }
  
  checkEnter(event) {
    if (event.key === "Enter") {
      this.go()
    }
  }

  async track(email) {
    // post to auth track with email in body
    try {
      await fetch("/auth/track", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ email }),
      })
    } catch (e) {
      console.error(e)
    }
  }
}
