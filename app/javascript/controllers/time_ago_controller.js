import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    includeSeconds: { type: Boolean, default: false }
  }

  connect() {
    this.updateTimeAgo()
    const interval = this.includeSecondsValue ? 1000 : 60000
    this.interval = setInterval(() => this.updateTimeAgo(), interval)
  }

  disconnect() {
    if (this.interval) {
      clearInterval(this.interval)
    }
  }

  updateTimeAgo() {
    const datetime = this.element.getAttribute("datetime")
    if (!datetime) return

    const fromTime = new Date(datetime)
    const toTime = new Date()
    const text = this.distanceInWords(fromTime, toTime, this.includeSecondsValue)
    this.element.textContent = text
  }

  distanceInWords(fromTime, toTime, includeSeconds = false) {
    if (fromTime > toTime) {
      [fromTime, toTime] = [toTime, fromTime]
    }

    const distanceInSeconds = Math.round((toTime - fromTime) / 1000)
    const distanceInMinutes = Math.round(distanceInSeconds / 60)

    if (distanceInMinutes >= 0 && distanceInMinutes <= 1) {
      if (!includeSeconds) {
        return distanceInMinutes === 0 ? "less than a minute" : "1 minute"
      }
      if (distanceInSeconds >= 0 && distanceInSeconds <= 4) return "less than 5 seconds"
      if (distanceInSeconds >= 5 && distanceInSeconds <= 9) return "less than 10 seconds"
      if (distanceInSeconds >= 10 && distanceInSeconds <= 19) return "less than 20 seconds"
      if (distanceInSeconds >= 20 && distanceInSeconds <= 39) return "half a minute"
      if (distanceInSeconds >= 40 && distanceInSeconds <= 59) return "less than a minute"
      return "1 minute"
    }
    if (distanceInMinutes >= 2 && distanceInMinutes < 45) {
      return distanceInMinutes + " minutes"
    }
    if (distanceInMinutes >= 45 && distanceInMinutes < 90) {
      return "about 1 hour"
    }
    if (distanceInMinutes >= 90 && distanceInMinutes < 1440) {
      const hours = Math.round(distanceInMinutes / 60)
      return "about " + hours + (hours === 1 ? " hour" : " hours")
    }
    if (distanceInMinutes >= 1440 && distanceInMinutes < 2520) {
      return "1 day"
    }
    if (distanceInMinutes >= 2520 && distanceInMinutes < 43200) {
      const days = Math.round(distanceInMinutes / 1440)
      return days + (days === 1 ? " day" : " days")
    }
    if (distanceInMinutes >= 43200 && distanceInMinutes < 86400) {
      const months = Math.round(distanceInMinutes / 43200)
      return "about " + months + (months === 1 ? " month" : " months")
    }
    if (distanceInMinutes >= 86400 && distanceInMinutes < 525600) {
      const months = Math.round(distanceInMinutes / 43200)
      return months + (months === 1 ? " month" : " months")
    }

    const MINUTES_IN_YEAR = 525600
    const MINUTES_IN_QUARTER_YEAR = 131400
    const MINUTES_IN_THREE_QUARTERS_YEAR = 394200

    let fromYear = fromTime.getFullYear()
    if (fromTime.getMonth() >= 2) fromYear++
    let toYear = toTime.getFullYear()
    if (toTime.getMonth() < 2) toYear--

    const leapYears = this.countLeapYears(fromYear, toYear)
    const minuteOffsetForLeapYear = leapYears * 1440
    const minutesWithOffset = distanceInMinutes - minuteOffsetForLeapYear

    const distanceInYears = Math.floor(minutesWithOffset / MINUTES_IN_YEAR)
    const remainder = minutesWithOffset % MINUTES_IN_YEAR

    let years, prefix
    if (remainder < MINUTES_IN_QUARTER_YEAR) {
      prefix = "about"
      years = distanceInYears
    } else if (remainder < MINUTES_IN_THREE_QUARTERS_YEAR) {
      prefix = "over"
      years = distanceInYears
    } else {
      prefix = "almost"
      years = distanceInYears + 1
    }

    return prefix + " " + years + (years === 1 ? " year" : " years")
  }

  countLeapYears(fromYear, toYear) {
    if (fromYear > toYear) return 0
    
    const leapYearsUpTo = (year) => {
      return Math.floor(year / 4) - Math.floor(year / 100) + Math.floor(year / 400)
    }
    
    return leapYearsUpTo(toYear) - leapYearsUpTo(fromYear - 1)
  }
}
