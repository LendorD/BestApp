// GameMentor design tokens with dark/light theme support.
// GM is a single mutable object: components read GM.bg etc. at render time.
// applyTheme() swaps the palette in place; the React tree re-renders and
// picks up the new values (this keeps alpha-hex like `${GM.border}55` working).

export const DOTA_ACCENT = '#00D084'
export const CS2_ACCENT = '#FF6B00'

const DARK = {
  bg: '#050608',
  card: '#0B0E13',
  surf: '#10141B',
  border: '#1B2430',
  borderSoft: 'rgba(27,36,48,0.6)',
  text: '#F4F6FA',
  muted: '#8A94A6',
  deep: '#5A6475',
  premium: '#D4AF37',
  red: '#FF4D61',
}

const LIGHT = {
  bg: '#F5F7FB',
  card: '#FFFFFF',
  surf: '#EDF1F7',
  border: '#D7DEE9',
  borderSoft: 'rgba(215,222,233,0.7)',
  text: '#0C1016',
  muted: '#5A6475',
  deep: '#8A94A6',
  premium: '#B07D17',
  red: '#E0344A',
}

export const THEMES = { dark: DARK, light: LIGHT }

// Live palette (mutated in place by applyTheme).
export const GM = { ...DARK }

export function applyTheme(name) {
  const palette = THEMES[name] || DARK
  Object.assign(GM, palette)
  try { localStorage.setItem('gm.theme', name) } catch { /* ignore */ }
  if (typeof document !== 'undefined' && document.body) {
    document.body.style.background = GM.bg
    document.body.style.color = GM.text
    document.documentElement.style.colorScheme = name === 'light' ? 'light' : 'dark'
  }
  return name
}

export function loadTheme() {
  let name = 'dark'
  try { name = localStorage.getItem('gm.theme') || 'dark' } catch { /* ignore */ }
  applyTheme(name)
  return name
}
