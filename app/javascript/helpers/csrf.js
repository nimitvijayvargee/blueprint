export function csrfToken() {
  const meta = document.querySelector('meta[name="csrf-token"]')
  return meta?.getAttribute("content") || ""
}

export function csrfHeader() {
  const token = csrfToken()
  return token ? { "X-CSRF-Token": token } : {}
}

export function authenticityParam() {
  const meta = document.querySelector('meta[name="csrf-param"]')
  return meta?.getAttribute("content") || "authenticity_token"
}
