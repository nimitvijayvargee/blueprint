import { Controller } from "@hotwired/stimulus"
import { csrfHeader } from "helpers/csrf"

// Detects user's timezone and updates it on the server
export default class extends Controller {
  static values = {
    endpoint: { type: String, default: "/users/update_timezone" }
  }

  connect() {
    this.detectAndUpdateTimezone()
    
    // Store the initial timezone in a cookie for comparison
    this.lastTimezone = this.getCookie("user_timezone") || ""
    
    // Check for timezone changes every 30 seconds
    this.intervalId = setInterval(() => {
      this.checkForTimezoneChange()
    }, 3000)
  }

  disconnect() {
    if (this.intervalId) {
      clearInterval(this.intervalId)
    }
  }

  detectAndUpdateTimezone() {
    const timezone = this.getCurrentTimezone()
    if (timezone) {
      const storedTimezone = this.getCookie("user_timezone")
      
      // Only update if timezone has changed or if we don't have one stored
      if (storedTimezone !== timezone) {
        this.updateTimezone(timezone)
      }
    }
  }

  checkForTimezoneChange() {
    const currentTimezone = this.getCurrentTimezone()
    if (currentTimezone && currentTimezone !== this.lastTimezone) {
      this.updateTimezone(currentTimezone)
      this.lastTimezone = currentTimezone
    }
  }

  getCurrentTimezone() {
    try {
      // Get timezone in IANA format (e.g., "America/New_York", "Europe/London")
      return Intl.DateTimeFormat().resolvedOptions().timeZone
    } catch (error) {
      console.warn("Could not detect timezone:", error)
      return null
    }
  }

  async updateTimezone(timezone) {
    try {
      const response = await fetch(this.endpointValue, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          ...csrfHeader()
        },
        body: JSON.stringify({ timezone: timezone })
      })

      const data = await response.json()
      
      if (data.ok) {
        // Store in cookie for future reference
        this.setCookie("user_timezone", timezone, 365)
      } else {
        console.error("Failed to update timezone:", data.error)
      }
    } catch (error) {
      console.error("Error updating timezone:", error)
    }
  }

  getCookie(name) {
    const value = `; ${document.cookie}`
    const parts = value.split(`; ${name}=`)
    if (parts.length === 2) {
      return parts.pop().split(';').shift()
    }
    return null
  }

  setCookie(name, value, days) {
    const expires = new Date()
    expires.setTime(expires.getTime() + (days * 24 * 60 * 60 * 1000))
    document.cookie = `${name}=${value};expires=${expires.toUTCString()};path=/`
  }
}