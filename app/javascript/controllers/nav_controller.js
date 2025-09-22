import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["link", "submenu", "sublink"]

  connect() {
    this.update = this.update.bind(this)
    document.addEventListener("turbo:load", this.update)
    document.addEventListener("turbo:render", this.update)
    this.update()
  }

  disconnect() {
    document.removeEventListener("turbo:load", this.update)
    document.removeEventListener("turbo:render", this.update)
  }

  update() {
    const currentPath = window.location.pathname

    // Toggle top-level nav active state (supports anchors or containers with data-nav-base or a child <a>)
    this.linkTargets.forEach((link) => {
      const match = link.dataset.navMatch || "exact"
      const explicitBase = (link.dataset.navBase || link.dataset.linkBase || link.dataset.navPath || "").replace(/\/$/, "")

      // Determine a pathname to compare against
      let pathname = ""
      if (explicitBase) {
        pathname = explicitBase
      } else if (link.pathname) {
        pathname = link.pathname.replace(/\/$/, "")
      } else {
        const a = link.querySelector && link.querySelector('a[href]')
        if (a) {
          try {
            pathname = new URL(a.getAttribute('href'), window.location.origin).pathname.replace(/\/$/, "")
          } catch (_) {}
        }
      }

      let isActive = false
      if (match === "prefix") {
        const base = pathname
        isActive = base && (currentPath === base || currentPath.startsWith(base + "/"))
      } else {
        isActive = pathname && pathname === currentPath
      }

      this.toggleVariant(link, isActive)
      if (isActive) link.setAttribute("aria-current", "page")
      else link.removeAttribute("aria-current")
    })

    // Toggle submenus based on base path
    this.submenuTargets.forEach((submenu) => {
      const base = (submenu.dataset.submenuBase || "").replace(/\/$/, "")
      const expanded = base && (currentPath === base || currentPath.startsWith(base + "/"))
      submenu.classList.toggle("hidden", !expanded)
    })

    // Update sublinks highlighting (underline active)
    if (this.hasSublinkTarget) {
      this.sublinkTargets.forEach((link) => {
        const match = link.dataset.navMatch || "exact"
        let isActive = false
        if (match === "prefix") {
          const base = link.pathname.replace(/\/$/, "")
          isActive = currentPath === base || currentPath.startsWith(base + "/")
        } else {
          isActive = link.pathname === currentPath
        }
        link.classList.toggle("underline", isActive)
        if (isActive) link.setAttribute("aria-current", "page")
        else link.removeAttribute("aria-current")
      })
    }
  }

  toggleVariant(el, active) {
    const ACTIVE = "btn-nav-active"
    const INACTIVE = "btn-nav"
    if (active) {
      el.classList.add(ACTIVE)
      el.classList.remove(INACTIVE)
    } else {
      el.classList.add(INACTIVE)
      el.classList.remove(ACTIVE)
    }
  }
}
