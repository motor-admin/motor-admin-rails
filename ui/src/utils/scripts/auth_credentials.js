import api from 'api'

const EXPIRATION_DURATION = 1 * 60 * 60 * 1000

let credentials = null
let loadedAt = null

async function loadCredentials () {
  if (credentials && !isCredentialsExpired()) {
    return credentials
  }

  let result

  try {
    result = await api.post('auth_tokens')
  } catch (error) {
    console.error(error)

    return { headers: {} }
  }

  if (typeof result.data === 'string') {
    credentials = { headers: { Authorization: normalizeToken(result.data) } }
  } else {
    const token = result.data.token || result.data.jwt

    if (token) {
      result.data.headers ||= {}
      result.data.headers.Authorization ||= normalizeToken(token)
    }

    credentials = result.data
  }

  loadedAt = new Date()

  return credentials
}

function normalizeToken (token) {
  if (token) {
    return `Bearer ${token.replace(/^bearer\s+/i, '')}`
  } else {
    return ''
  }
}

function isCredentialsExpired () {
  if (loadedAt) {
    return EXPIRATION_DURATION < (new Date().getTime() - loadedAt.getTime())
  } else {
    return true
  }
}

export { loadCredentials }
