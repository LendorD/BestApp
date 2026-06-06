// GameMentor API client - matches the Go backend (internal/delivery/http/router.go)
const BASE = '/api/v1'

async function request(path, opts = {}) {
  const res = await fetch(BASE + path, {
    headers: { 'Content-Type': 'application/json', ...opts.headers },
    ...opts,
  })
  let json
  try { json = await res.json() } catch { throw new Error(`HTTP ${res.status}`) }
  if (!res.ok || json.success === false) {
    throw new Error(json?.error?.message || `HTTP ${res.status}`)
  }
  return json.data
}

// Auth
export const auth = {
  register: (body) => request('/auth/register', { method: 'POST', body: JSON.stringify(body) }),
  login: (body) => request('/auth/login', { method: 'POST', body: JSON.stringify(body) }),
}

// Users
export const users = {
  getProfile: (id) => request(`/users/${id}/profile`),
  updateProfile: (id, body) => request(`/users/${id}/profile`, { method: 'PUT', body: JSON.stringify(body) }),
}

// Dota Lab (analytics module)
export const dota = {
  getDashboard: (steamId, params = {}) => {
    const q = new URLSearchParams(params).toString()
    return request(`/dota/lab/players/${steamId}/dashboard${q ? '?' + q : ''}`)
  },
  getProComparison: (steamId, params = {}) => {
    const q = new URLSearchParams(params).toString()
    return request(`/dota/lab/players/${steamId}/pro-comparison${q ? '?' + q : ''}`)
  },
  getHeroes: (steamId, params = {}) => {
    const q = new URLSearchParams(params).toString()
    return request(`/dota/lab/players/${steamId}/heroes${q ? '?' + q : ''}`)
  },
  getForm: (steamId) => request(`/dota/lab/players/${steamId}/form`),
  getWeaknesses: (steamId) => request(`/dota/lab/players/${steamId}/weaknesses`),
  getAICoachPreview: (steamId) => request(`/dota/lab/players/${steamId}/ai-coach-preview`),
  refresh: (steamId, params = {}) => {
    const q = new URLSearchParams(params).toString()
    return request(`/dota/lab/players/${steamId}/refresh${q ? '?' + q : ''}`, { method: 'POST' })
  },
}

// Identity
export const identity = {
  resolveDota: (body) => request('/identity/dota/resolve', { method: 'POST', body: JSON.stringify(body) }),
}

// AI Coach (ai_coach module)
export const aiCoach = {
  review: (steamId) => request(`/ai-coach/dota/player/${steamId}/review`, { method: 'POST' }),
  latest: (steamId) => request(`/ai-coach/dota/player/${steamId}/latest`),
  reviewMatch: (matchId, steamId = '') => {
    const q = steamId ? `?steam_id=${encodeURIComponent(steamId)}` : ''
    return request(`/ai-coach/dota/match/${matchId}/review${q}`, { method: 'POST' })
  },
  getReport: (reportId) => request(`/ai-coach/reports/${reportId}`),
}

// CS2
export const cs2 = {
  getMaps: () => request('/cs2/maps'),
  getGrenades: (params = {}) => {
    const q = new URLSearchParams(params).toString()
    return request(`/cs2/grenades${q ? '?' + q : ''}`)
  },
  getGrenade: (id) => request(`/cs2/grenades/${id}`),
  createGrenade: (body) => request('/cs2/grenades', { method: 'POST', body: JSON.stringify(body) }),
  updateGrenade: (id, body) => request(`/cs2/grenades/${id}`, { method: 'PUT', body: JSON.stringify(body) }),
  deleteGrenade: (id) => request(`/cs2/grenades/${id}`, { method: 'DELETE' }),
}
