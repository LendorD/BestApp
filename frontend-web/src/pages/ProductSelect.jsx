import { useNavigate } from 'react-router-dom'
import { GM, DOTA_ACCENT, CS2_ACCENT } from '../lib/theme.js'
import { Card, Kicker, Badge, Icon } from '../components/primitives.jsx'

export default function ProductSelect({ setGame, theme, setTheme }) {
  const nav = useNavigate()
  const isLight = theme === 'light'

  const choose = (g) => {
    setGame(g)
    nav(`/${g}`)
  }

  return (
    <div style={{ minHeight: '100vh', background: GM.bg, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: 24, position: 'relative' }}>
      {/* grid bg */}
      <div style={{ position: 'fixed', inset: 0, backgroundImage: `linear-gradient(${GM.border}55 1px, transparent 1px), linear-gradient(90deg, ${GM.border}55 1px, transparent 1px)`, backgroundSize: '56px 56px', opacity: 0.3, pointerEvents: 'none' }} />

      <div onClick={() => setTheme && setTheme(isLight ? 'dark' : 'light')} title="Сменить тему" style={{
        position: 'fixed', top: 18, right: 18, zIndex: 2,
        width: 40, height: 40, borderRadius: 10, background: GM.card,
        border: `1px solid ${GM.border}`, display: 'flex', alignItems: 'center',
        justifyContent: 'center', color: GM.muted, cursor: 'pointer',
      }}><Icon name={isLight ? 'moon' : 'sun'} size={18} /></div>

      <div style={{ position: 'relative', zIndex: 1, maxWidth: 900, width: '100%' }}>
        {/* Logo */}
        <div style={{ textAlign: 'center', marginBottom: 52 }}>
          <div style={{ display: 'inline-flex', alignItems: 'center', gap: 14, marginBottom: 20 }}>
            <div style={{ width: 52, height: 52, borderRadius: 12, background: GM.card, border: `1px solid ${DOTA_ACCENT}`, display: 'flex', alignItems: 'center', justifyContent: 'center', color: DOTA_ACCENT, fontWeight: 900, fontSize: 26 }}>G</div>
            <div style={{ fontSize: 34, fontWeight: 900, letterSpacing: '-0.03em' }}>GameMentor</div>
          </div>
          <div style={{ fontSize: 18, color: GM.muted, fontWeight: 600, maxWidth: 460, margin: '0 auto' }}>
            Премиум аналитика для Dota 2 и CS2. Выберите игру, чтобы начать.
          </div>
        </div>

        {/* Cards */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(340px, 1fr))', gap: 20 }}>
          {/* Dota */}
          <div onClick={() => choose('dota')} style={{ cursor: 'pointer' }}>
            <Card glow accent={DOTA_ACCENT} pad={32} style={{
              border: `1px solid ${DOTA_ACCENT}44`,
              transition: 'transform 0.15s, box-shadow 0.15s',
            }}
              onMouseEnter={e => { e.currentTarget.style.transform = 'translateY(-4px)'; e.currentTarget.style.boxShadow = `0 20px 60px -20px ${DOTA_ACCENT}44` }}
              onMouseLeave={e => { e.currentTarget.style.transform = ''; e.currentTarget.style.boxShadow = '' }}
            >
              <Kicker color={DOTA_ACCENT} style={{ marginBottom: 12 }}>DOTA 2 LAB</Kicker>
              <div style={{ fontSize: 32, fontWeight: 900, marginBottom: 12, letterSpacing: '-0.02em' }}>Dota 2</div>
              <div style={{ fontSize: 14, color: GM.muted, lineHeight: 1.6, marginBottom: 24 }}>
                Анализ по OpenDota: MMR-тренд, GPM/XPM, hero pool, сравнение с про-игроками и AI Coach план роста.
              </div>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8, marginBottom: 24 }}>
                {['GameMentor Score', 'Skill Radar', 'Match Review', 'Pro Benchmark', 'AI Coach', 'Hero Pool'].map(f => (
                  <Badge key={f} color={DOTA_ACCENT}>{f}</Badge>
                ))}
              </div>
              <button style={{
                width: '100%', padding: '14px 0', borderRadius: 8, border: 'none',
                background: DOTA_ACCENT, color: GM.bg, fontWeight: 800, fontSize: 15,
                fontFamily: 'inherit', cursor: 'pointer', letterSpacing: '-0.01em',
              }}>
                Открыть Dota 2 Lab →
              </button>
            </Card>
          </div>

          {/* CS2 */}
          <div onClick={() => choose('cs2')} style={{ cursor: 'pointer' }}>
            <Card glow accent={CS2_ACCENT} pad={32} style={{
              border: `1px solid ${CS2_ACCENT}44`,
              transition: 'transform 0.15s, box-shadow 0.15s',
            }}
              onMouseEnter={e => { e.currentTarget.style.transform = 'translateY(-4px)'; e.currentTarget.style.boxShadow = `0 20px 60px -20px ${CS2_ACCENT}44` }}
              onMouseLeave={e => { e.currentTarget.style.transform = ''; e.currentTarget.style.boxShadow = '' }}
            >
              <Kicker color={CS2_ACCENT} style={{ marginBottom: 12 }}>CS2 LAB</Kicker>
              <div style={{ fontSize: 32, fontWeight: 900, marginBottom: 12, letterSpacing: '-0.02em' }}>CS2</div>
              <div style={{ fontSize: 14, color: GM.muted, lineHeight: 1.6, marginBottom: 24 }}>
                K/D, ADR, HS%, Clutch%, util damage — полная аналитика + карты гранат, утилити-сеты и разбор раундов.
              </div>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8, marginBottom: 24 }}>
                {['K/D Trend', 'Skill Radar', 'Grenade Maps', 'Utility Sets', 'Clutch Stats', 'AI Coach'].map(f => (
                  <Badge key={f} color={CS2_ACCENT}>{f}</Badge>
                ))}
              </div>
              <button style={{
                width: '100%', padding: '14px 0', borderRadius: 8, border: 'none',
                background: CS2_ACCENT, color: GM.bg, fontWeight: 800, fontSize: 15,
                fontFamily: 'inherit', cursor: 'pointer', letterSpacing: '-0.01em',
              }}>
                Открыть CS2 Lab →
              </button>
            </Card>
          </div>
        </div>

        <div style={{ textAlign: 'center', marginTop: 32, fontSize: 13, color: GM.deep }}>
          Нет аккаунта?{' '}
          <span onClick={() => nav('/register')} style={{ color: DOTA_ACCENT, cursor: 'pointer', fontWeight: 700 }}>Зарегистрироваться</span>
        </div>
      </div>
    </div>
  )
}
