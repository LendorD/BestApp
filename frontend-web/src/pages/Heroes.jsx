import { useState, useEffect } from 'react'
import { GM, DOTA_ACCENT, CS2_ACCENT } from '../lib/theme.js'
import { Card, Kicker, Badge, Icon, Mono, Stack, SectionTitle, Meter } from '../components/primitives.jsx'
import { heroName } from '../lib/dotaHeroes.js'
import { heroPortrait } from '../lib/dotaHeroImages.js'
import { dota } from '../lib/api.js'
import { profile } from '../lib/storage.js'

const CS2_WEAPONS = [
  { name: 'AK-47', role: 'Rifle', winrate: 58, matches: 142 },
  { name: 'M4A1-S', role: 'Rifle', winrate: 54, matches: 98 },
  { name: 'AWP', role: 'Sniper', winrate: 61, matches: 76 },
  { name: 'Desert Eagle', role: 'Pistol', winrate: 49, matches: 64 },
  { name: 'USP-S', role: 'Pistol', winrate: 52, matches: 88 },
  { name: 'Galil AR', role: 'Rifle', winrate: 46, matches: 31 },
]

// 3D tilt card with the real Dota hero portrait.
function Hero3DCard({ id, name, role, winrate, matches, kda, accent }) {
  const [t, setT] = useState({ rx: 0, ry: 0, s: 1 })
  const [broken, setBroken] = useState(false)
  const img = heroPortrait(id)
  const wrColor = winrate >= 55 ? accent : winrate < 48 ? GM.red : GM.muted

  const onMove = (e) => {
    const r = e.currentTarget.getBoundingClientRect()
    const px = (e.clientX - r.left) / r.width - 0.5
    const py = (e.clientY - r.top) / r.height - 0.5
    setT({ rx: -py * 12, ry: px * 16, s: 1.03 })
  }
  const reset = () => setT({ rx: 0, ry: 0, s: 1 })
  const active = t.s > 1

  return (
    <div onMouseMove={onMove} onMouseLeave={reset} style={{ perspective: 900 }}>
      <div style={{
        position: 'relative', borderRadius: 10, overflow: 'hidden',
        background: GM.card, border: `1px solid ${active ? accent + '66' : GM.border}`,
        transform: `rotateX(${t.rx}deg) rotateY(${t.ry}deg) scale(${t.s})`,
        transformStyle: 'preserve-3d', transition: 'transform 0.12s ease-out, border-color 0.15s',
        boxShadow: active ? `0 26px 54px -24px ${accent}66` : '0 12px 30px -22px rgba(0,0,0,0.9)',
      }}>
        <div style={{ position: 'relative', height: 120, overflow: 'hidden', background: GM.surf }}>
          {img && !broken ? (
            <img src={img} alt={name} loading="lazy" onError={() => setBroken(true)}
              style={{ width: '100%', height: '100%', objectFit: 'cover', display: 'block',
                transform: `translateZ(40px) scale(${active ? 1.08 : 1})`, transition: 'transform 0.25s ease-out' }} />
          ) : (
            <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', color: GM.deep }}>
              <Icon name="cube" size={30} color={GM.deep} />
            </div>
          )}
          <div style={{ position: 'absolute', inset: 0, pointerEvents: 'none', background: `radial-gradient(120% 80% at 50% 0%, ${accent}38, transparent 60%)` }} />
          <div style={{ position: 'absolute', left: 0, right: 0, bottom: 0, height: 50, background: `linear-gradient(transparent, ${GM.card})`, pointerEvents: 'none' }} />
          <div style={{ position: 'absolute', top: 8, right: 8, transform: 'translateZ(55px)' }}>
            <span style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: 11, fontWeight: 700, color: GM.bg, background: wrColor, padding: '3px 7px', borderRadius: 5 }}>{winrate}%</span>
          </div>
        </div>
        <div style={{ padding: '10px 14px 14px', transform: 'translateZ(30px)' }}>
          <div style={{ fontSize: 14, fontWeight: 800, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{name}</div>
          {role ? <Mono style={{ fontSize: 10.5, color: GM.deep }}>{role}</Mono> : null}
          <div style={{ marginTop: 8 }}><Meter value={winrate} accent={wrColor} glow={winrate >= 55} /></div>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 8 }}>
            <span style={{ fontSize: 11.5, color: GM.muted }}>{matches} матчей</span>
            {kda != null && <Mono style={{ fontSize: 11.5, color: GM.text }}>KDA {Number(kda).toFixed(2)}</Mono>}
          </div>
        </div>
      </div>
    </div>
  )
}

function WeaponCard({ name, role, winrate, matches, accent }) {
  const wrColor = winrate >= 55 ? accent : winrate < 48 ? GM.red : GM.muted
  return (
    <Card pad={16}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 12 }}>
        <div style={{ width: 42, height: 42, borderRadius: 8, background: GM.surf, border: `1px solid ${GM.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: "'JetBrains Mono', monospace", fontSize: 13, fontWeight: 800, color: accent }}>{name.slice(0, 2).toUpperCase()}</div>
        <div style={{ minWidth: 0 }}>
          <div style={{ fontSize: 14, fontWeight: 800 }}>{name}</div>
          <Mono style={{ fontSize: 10.5, color: GM.deep }}>{role}</Mono>
        </div>
      </div>
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
        <Kicker>Winrate</Kicker>
        <Mono style={{ fontSize: 12, fontWeight: 700, color: wrColor }}>{winrate}%</Mono>
      </div>
      <Meter value={winrate} accent={wrColor} glow={winrate >= 55} />
      <div style={{ marginTop: 12, fontSize: 11.5, color: GM.muted }}>{matches} матчей</div>
    </Card>
  )
}

export default function Heroes({ game = 'dota' }) {
  const accent = game === 'cs2' ? CS2_ACCENT : DOTA_ACCENT
  const isCs = game === 'cs2'
  const [data, setData] = useState({ best: [], problem: [] })
  const [loading, setLoading] = useState(!isCs)

  useEffect(() => {
    if (isCs) return
    const id = profile.getDotaId() || '369102305'
    setLoading(true)
    dota.getHeroes(id)
      .then(res => setData({ best: res?.best || [], problem: res?.problem || [] }))
      .catch(() => setData({ best: [], problem: [] }))
      .finally(() => setLoading(false))
  }, [isCs])

  if (isCs) {
    return (
      <Stack gap={16}>
        <Card glow accent={accent} pad={20} style={{ borderColor: `${accent}33` }}>
          <SectionTitle title="Weapon Pool" sub="Эффективность по оружию (демо)" right={<Badge color={accent}>CS2</Badge>} />
        </Card>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(220px, 1fr))', gap: 12 }}>
          {CS2_WEAPONS.map(w => <WeaponCard key={w.name} {...w} accent={accent} />)}
        </div>
      </Stack>
    )
  }

  return (
    <Stack gap={16}>
      <Card glow accent={accent} pad={20} style={{ borderColor: `${accent}33` }}>
        <SectionTitle title="Hero Pool" sub="Лучшие и проблемные герои по последним матчам" right={<Badge color={accent}>DOTA 2</Badge>} />
      </Card>

      {loading ? (
        <div style={{ textAlign: 'center', padding: 40, color: GM.muted }}>Загрузка…</div>
      ) : (
        <>
          <div>
            <Kicker color={accent} style={{ display: 'block', marginBottom: 10 }}>★ Лучшие герои</Kicker>
            {data.best.length ? (
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(210px, 1fr))', gap: 14 }}>
                {data.best.map(h => (
                  <Hero3DCard key={h.hero_id} id={h.hero_id} name={heroName(h.hero_id)} role={h.role}
                    winrate={Math.round(h.winrate)} matches={h.matches} kda={h.average_kda} accent={accent} />
                ))}
              </div>
            ) : <EmptyHint />}
          </div>

          <div>
            <Kicker color={GM.red} style={{ display: 'block', marginBottom: 10 }}>▼ Проблемные герои</Kicker>
            {data.problem.length ? (
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(210px, 1fr))', gap: 14 }}>
                {data.problem.map(h => (
                  <Hero3DCard key={h.hero_id} id={h.hero_id} name={heroName(h.hero_id)} role={h.role}
                    winrate={Math.round(h.winrate)} matches={h.matches} kda={h.average_kda} accent={accent} />
                ))}
              </div>
            ) : <EmptyHint />}
          </div>
        </>
      )}
    </Stack>
  )
}

function EmptyHint() {
  return (
    <Card pad={28} style={{ textAlign: 'center', border: `1px dashed ${GM.border}` }}>
      <div style={{ fontSize: 13, color: GM.muted }}>Нет данных. Задай Dota ID в профиле или запусти backend.</div>
    </Card>
  )
}
