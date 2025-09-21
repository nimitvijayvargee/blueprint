import { Controller } from "@hotwired/stimulus"
import { csrfHeader } from "helpers/csrf"

export default class extends Controller {
    static targets = ["button1", "button2"]

    static values = {
        targetId: String
    }

    connect() {
        console.log(this.targetIdValue)
    }

    sendInvite() {
        if (!this.hasButton1Target) return
        
        this.button1Target.innerText = "Sending..."
        this.button1Target.disabled = true

        // post to /users/invite_to_slack
        fetch("/users/invite_to_slack", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                ...csrfHeader()
            },
            body: JSON.stringify({})
        }).then(response => {
            console.log(response)
            if (response.ok) {
                this.dispatch(`modal:next-${this.targetIdValue}`, { target: window, prefix: false })
            } else {
                this.button1Target.innerText = "Error, try again?"
                this.button1Target.disabled = false
            }
        }).catch(error => {
            console.error("Error:", error)
            this.button1Target.innerText = "Error, try again?"
            this.button1Target.disabled = false
        });
    }

    checkVerified() {
        if (!this.hasButton2Target) return
        
        this.button2Target.innerText = "Running some checks..."
        this.button2Target.disabled = true

        fetch("/users/mcg_check", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                ...csrfHeader()
            },
            body: JSON.stringify({})
        }).then(async response => {
            if (!response.ok) {
                this.button2Target.innerText = "Error, try again?"
                this.button2Target.disabled = false
                return
            }
            const data = await response.json()
            if (!data.is_mcg) {
                window.location.reload()
            } else {
                this.button2Target.innerText = "You're not verified!"
                this.button2Target.disabled = false
            }
        }).catch(() => {
            this.button2Target.innerText = "Error, try again?"
            this.button2Target.disabled = false
        })
    }
}
