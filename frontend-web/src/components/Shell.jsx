import { useNavigate, useLocation } from 'react-router-dom'
import { GM, DOTA_ACCENT, CS2_ACCENT } from '../lib/theme.js'
import { Icon, Kicker, Mono, Badge } from './primitives.jsx'

const NAV = {
  dota: [
    { label: 'Dashboard',    icon: 'grid',   path: '/dota',            active: true },
    { label: 'Мой профиль',  icon: 'user',   path: '/profile' },
    { label: 'AI Coach',     icon: 'spark',  path: '/dota/ai-coach',   pro: true },
    { label: 'Match Review', icon: 'search', path: '/dota/player' },
    { label: 'Heroes',       icon: 'cube',   path: '/dota/heroes' },
    { label: 'Training',     icon: 'target', path: '/dota/training' },
    { label: 'Meta',         icon: 'graph',  path: '/dota/meta' },
    { label: 'Subscription', icon: 'crown',  path: '/dota/subscription', pro: true },
  ],
  cs2: [
    { label: 'Dashboard',    icon: 'grid',    path: '/cs2' },
    { label: 'Maps',         icon: 'pin',     path: '/cs2/maps' },
    { label: 'Grenades',     icon: 'drop',    path: '/cs2/grenades' },
    { label: 'Training',     icon: 'target',  path: '/cs2/training' },
    { label: 'Utility Sets', icon: 'squares', path: '/cs2/sets' },
    { label: 'AI Coach',     icon: 'spark',   path: '/cs2/ai-coach',    pro: true },
    { label: 'Subscription', icon: 'crown',   path: '/cs2/subscription', pro: true },
  ],
}

export function Sidebar({ game, setGame }) {
  const nav = useNavigate()
  const location = useLocation()
  const accent = game === 'dota' ? DOTA_ACCENT : CS2_ACCENT
  const items = NAV[game] || NAV.dota

  return (
    <aside style={{
      width: 244, flexShrink: 0, background: GM.card,
      borderRight: `1px solid ${GM.border}`,
      padding: '20px 14px', display: 'flex', flexDirection: 'column', gap: 18,
      height: '100vh', position: 'sticky', top: 0, overflowY: 'auto',
    }}>
      {/* Brand */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 11, padding: '0 4px' }}>
        <div style={{
          width: 38, height: 38, borderRadius: 8, background: GM.bg,
          border: `1px solid ${accent}`, display: 'flex', alignItems: 'center',
          justifyContent: 'center', color: accent, fontWeight: 900, fontSize: 19,
        }}>G</div>
        <div>
          <div style={{ fontWeight: 900, fontSize: 16, letterSpacing: '-0.02em' }}>GameMentor</div>
          <div style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: 9.5, letterSpacing: '0.14em', color: accent }}>
            {game === 'dota' ? 'DOTA 2 LAB' : 'CS2 LAB'}
          </div>
        </div>
      </div>

      {/* Game switcher */}
      <div style={{ display: 'flex', gap: 4, padding: 4, background: GM.bg, border: `1px solid ${GM.border}`, borderRadius: 8 }}>
        {[['dota', 'Dota 2', DOTA_ACCENT], ['cs2', 'CS2', CS2_ACCENT]].map(([g, lbl, c]) => (
          <button key={g} onClick={() => { setGame(g); nav(`/${g}`) }} style={{
            flex: 1, border: 'none', cursor: 'pointer',
            padding: '8px 0', borderRadius: 6,
            fontWeight: 800, fontSize: 12.5, fontFamily: 'inherit',
            background: game === g ? c : 'transparent',
            color: game === g ? GM.bg : GM.muted,
          }}>{lbl}</button>
        ))}
      </div>

      {/* Nav */}
      <div>
        <Kicker style={{ padding: '0 6px' }}>Menu</Kicker>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 3, marginTop: 9 }}>
          {items.map((n) => {
            const isActive = location.pathname === n.path || (n.path !== '/' + game && location.pathname.startsWith(n.path + '/'))
            return (
              <div key={n.label}
                onClick={() => nav(n.path)}
                style={{
                  position: 'relative', display: 'flex', alignItems: 'center', gap: 11,
                  padding: '9px 11px', borderRadius: 7, cursor: 'pointer',
                  color: isActive ? GM.text : GM.muted,
                  background: isActive ? `${accent}14` : 'transparent',
                  border: `1px solid ${isActive ? accent + '3a' : 'transparent'}`,
                  fontWeight: isActive ? 800 : 600, fontSize: 13.5,
                }}>
                {isActive && <div style={{ position: 'absolute', left: -14, top: 8, bottom: 8, width: 3, borderRadius: 2, background: accent }} />}
                <Icon name={n.icon} size={17} color={isActive ? accent : GM.deep} />
                <span style={{ flex: 1 }}>{n.label}</span>
                {n.pro && (
                  <Mono style={{ fontSize: 8.5, fontWeight: 700, letterSpacing: '0.1em', color: GM.premium, border: `1px solid ${GM.premium}55`, borderRadius: 4, padding: '1px 4px' }}>PRO</Mono>
                )}
              </div>
            )
          })}
        </div>
      </div>

      {/* Live API status */}
      <div style={{ marginTop: 'auto', padding: 12, background: GM.bg, border: `1px solid ${GM.border}`, borderRadius: 8 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <span style={{ width: 7, height: 7, borderRadius: 999, background: DOTA_ACCENT, boxShadow: `0 0 6px ${DOTA_ACCENT}` }} />
          <Mono style={{ fontSize: 11, fontWeight: 600, color: GM.text }}>Live API</Mono>
        </div>
        <div style={{ fontSize: 10.5, color: GM.deep, marginTop: 5, fontFamily: "'JetBrains Mono', monospace" }}>OpenDota · synced 2m ago</div>
      </div>
    </aside>
  )
}

export function TopBar({ game, accent, playerName, theme, setTheme }) {
  const nav = useNavigate()
  const isLight = theme === 'light'
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 16, padding: '14px 26px',
      borderBottom: `1px solid ${GM.border}`, background: isLight ? 'rgba(255,255,255,0.72)' : 'rgba(8,11,16,0.6)',
      position: 'sticky', top: 0, zIndex: 100,
      backdropFilter: 'blur(12px)', WebkitBackdropFilter: 'blur(12px)',
    }}>
      <div style={{ flex: 1 }}>
        <Kicker color={GM.deep}>{game === 'dota' ? 'DOTA 2 LAB' : 'CS2 LAB'} / OVERVIEW</Kicker>
        <div style={{ fontSize: 17, fontWeight: 800, letterSpacing: '-0.01em', marginTop: 2 }}>Player Dashboard</div>
      </div>
      <div style={{ display: 'flex', alignItems: 'center', background: GM.card, border: `1px solid ${GM.border}`, borderRadius: 8, padding: '8px 12px', gap: 9, width: 240 }}>
        <Icon name="search" size={15} color={GM.deep} />
        <Mono style={{ fontSize: 12, color: GM.deep }}>Search player ID…</Mono>
      </div>
      <Badge color={GM.premium}>◆ PREMIUM</Badge>
      <div style={{ display: 'flex', gap: 8 }}>
        <div onClick={() => setTheme && setTheme(isLight ? 'dark' : 'light')} title="Сменить тему" style={{
          width: 38, height: 38, borderRadius: 8, background: GM.card,
          border: `1px solid ${GM.border}`, display: 'flex', alignItems: 'center',
          justifyContent: 'center', color: GM.muted, cursor: 'pointer',
        }}><Icon name={isLight ? 'moon' : 'sun'} size={17} /></div>
        {['bell', 'gear'].map((i) => (
          <div key={i} onClick={() => i === 'gear' && nav('/profile')} style={{
            width: 38, height: 38, borderRadius: 8, background: GM.card,
            border: `1px solid ${GM.border}`, display: 'flex', alignItems: 'center',
            justifyContent: 'center', color: GM.muted, cursor: 'pointer',
          }}><Icon name={i} size={17} /></div>
        ))}
        <div style={{
          width: 38, height: 38, borderRadius: 8,
          background: `linear-gradient(150deg, ${GM.surf}, ${GM.bg})`,
          border: `1px solid ${accent}`, boxShadow: `0 0 0 3px ${accent}1c`,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontSize: 15, fontWeight: 900, color: accent, cursor: 'pointer',
        }} onClick={() => nav('/profile')}>
          {(playerName || 'U')[0].toUpperCase()}
        </div>
      </div>
    </div>
  )
}

export function AppShell({ children, game, setGame, theme, setTheme }) {
  const location = useLocation()
  const accent = game === 'dota' ? DOTA_ACCENT : CS2_ACCENT
  const hideSidebar = location.pathname === '/product-select' || location.pathname === '/register'

  return (
    <div style={{ display: 'flex', minHeight: '100vh', background: GM.bg, color: GM.text, position: 'relative' }}>
      {/* Grid background */}
      <div style={{
        position: 'fixed', inset: 0, zIndex: 0,
        backgroundImage: `linear-gradient(${GM.border}55 1px, transparent 1px), linear-gradient(90deg, ${GM.border}55 1px, transparent 1px)`,
        backgroundSize: '56px 56px', opacity: 0.3, pointerEvents: 'none',
      }} />
      {!hideSidebar && <Sidebar game={game} setGame={setGame} />}
      <div style={{ flex: 1, minWidth: 0, position: 'relative', zIndex: 1, display: 'flex', flexDirection: 'column' }}>
        {!hideSidebar && <TopBar game={game} accent={accent} theme={theme} setTheme={setTheme} />}
        <main style={{ flex: 1, padding: hideSidebar ? 0 : 22 }}>
          {children}
        </main>
      </div>
    </div>
  )
}
