import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["button"]

    static values = {
        targetId: String
    }

    connect() {
        console.log(this.targetIdValue)
    }

    sendInvite() {
        if (!this.hasButtonTarget) return

        this.buttonTarget.innerText = "Sending..."
        this.buttonTarget.disabled = true

        // post to /users/invite_to_slack
        fetch("/users/invite_to_slack", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
            },
            body: JSON.stringify({})
        }).then(response => {
            console.log(response)
            if (response.ok) {
                this.dispatch(`modal:next-${this.targetIdValue}`, { target: window, prefix: false })
            } else {
                this.buttonTarget.innerText = "Error, try again"
                this.buttonTarget.disabled = false
            }
        })
    }
}
