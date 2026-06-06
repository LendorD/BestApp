import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { GM, CS2_ACCENT } from '../lib/theme.js'
import { Card, Kicker, Badge, Icon, Mono, Stack, SectionTitle } from '../components/primitives.jsx'
import { cs2 } from '../lib/api.js'

const FALLBACK_MAPS = [
  { name: 'Mirage', grenades: 24, winrate: 53 },
  { name: 'Inferno', grenades: 31, winrate: 51 },
  { name: 'Nuke', grenades: 18, winrate: 49 },
  { name: 'Dust II', grenades: 22, winrate: 55 },
  { name: 'Ancient', grenades: 16, winrate: 48 },
  { name: 'Anubis', grenades: 14, winrate: 47 },
  { name: 'Vertigo', grenades: 12, winrate: 50 },
]

export default function CS2Maps() {
  const accent = CS2_ACCENT
  const nav = useNavigate()
  const [maps, setMaps] = useState(FALLBACK_MAPS)

  useEffect(() => {
    cs2.getMaps()
      .then(res => {
        if (Array.isArray(res) && res.length) {
          setMaps(res.map(m => ({
            name: m.name || m.displayName || m,
            grenades: m.grenades ?? m.grenade_count ?? 0,
            winrate: m.winrate ?? 50,
          })))
        }
      })
      .catch(() => {})
  }, [])

  return (
    <Stack gap={16}>
      <Card glow accent={accent} pad={20} style={{ borderColor: `${accent}33` }}>
        <SectionTitle
          title={<span style={{ display: 'inline-flex', alignItems: 'center', gap: 8 }}><Icon name="pin" size={18} color={accent} /> Карты</span>}
          sub="Активный пул Premier · база раскидок по каждой карте"
          right={<Badge color={accent}>{maps.length} карт</Badge>}
        />
      </Card>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(240px, 1fr))', gap: 12 }}>
        {maps.map(m => (
          <Card key={m.name} pad={0} style={{ cursor: 'pointer', overflow: 'hidden' }}
            onClick={() => nav('/cs2/grenades')}
            onMouseEnter={e => e.currentTarget.style.borderColor = accent}
            onMouseLeave={e => e.currentTarget.style.borderColor = GM.border}>
            <div style={{ height: 96, background: `linear-gradient(135deg, ${GM.surf}, ${GM.bg})`, borderBottom: `1px solid ${GM.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative' }}>
              <div style={{ position: 'absolute', inset: 0, backgroundImage: `linear-gradient(${accent}10 1px, transparent 1px), linear-gradient(90deg, ${accent}10 1px, transparent 1px)`, backgroundSize: '20px 20px' }} />
              <Icon name="pin" size={30} color={accent} />
            </div>
            <div style={{ padding: 16 }}>
              <div style={{ fontSize: 16, fontWeight: 800, marginBottom: 8 }}>{m.name}</div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6, fontSize: 12, color: GM.muted }}>
                  <Icon name="drop" size={13} color={GM.deep} /> {m.grenades} раскидок
                </span>
                <Mono style={{ fontSize: 12, fontWeight: 700, color: m.winrate >= 52 ? accent : GM.muted }}>{m.winrate}% WR</Mono>
              </div>
            </div>
          </Card>
        ))}
      </div>
    </Stack>
  )
}
