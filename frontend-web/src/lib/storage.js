// Small persistence helpers (localStorage with safe fallbacks)
const KEYS = {
  dotaId: 'gm.dotaId',
  name: 'gm.name',
  game: 'gm.game',
}

function get(key, fallback = '') {
  try { return localStorage.getItem(key) ?? fallback } catch { return fallback }
}
function set(key, value) {
  try { localStorage.setItem(key, value) } catch { /* ignore */ }
}

export const profile = {
  getDotaId: () => get(KEYS.dotaId, ''),
  setDotaId: (v) => set(KEYS.dotaId, v),
  getName: () => get(KEYS.name, ''),
  setName: (v) => set(KEYS.name, v),
}
