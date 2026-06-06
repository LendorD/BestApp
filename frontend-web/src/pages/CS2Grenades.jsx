import { useState, useEffect } from 'react'
import { GM, CS2_ACCENT } from '../lib/theme.js'
import { Card, Kicker, Badge, Icon, Mono, SectionTitle, Stack } from '../components/primitives.jsx'
import { cs2 } from '../lib/api.js'

const MAPS = ['Mirage', 'Inferno', 'Nuke', 'Dust II', 'Ancient', 'Anubis', 'Vertigo']
const GRENADE_TYPES = [
  { type: 'smoke',   label: 'Smoke',   color: '#8A94A6' },
  { type: 'flash',   label: 'Flash',   color: '#F4F6FA' },
  { type: 'molotov', label: 'Molotov', color: '#FF6B00' },
  { type: 'he',      label: 'HE',      color: '#FF4D61' },
]

const MOCK_GRENADES = [
  { id: 1, map: 'Mirage', type: 'smoke', side: 'T', name: 'A Site Window Smoke', description: 'Убирает ротацию с Window' },
  { id: 2, map: 'Mirage', type: 'smoke', side: 'T', name: 'CT Smoke', description: 'Закрывает выход CT в A' },
  { id: 3, map: 'Mirage', type: 'flash', side: 'T', name: 'A Ramp Flash',  description: 'Слепит игроков на рампе' },
  { id: 4, map: 'Mirage', type: 'molotov', side: 'T', name: 'A Site Jungle Molotov', description: 'Выбивает из угла за ящиками' },
  { id: 5, map: 'Inferno', type: 'smoke', side: 'T', name: 'Banana Smoke', description: 'Закрывает Banana с T' },
  { id: 6, map: 'Inferno', type: 'smoke', side: 'CT', name: 'B Site Smoke', description: 'CT дефенс B' },
  { id: 7, map: 'Nuke', type: 'smoke', side: 'CT', name: 'Upper CT Smoke', description: 'Закрывает рампу с CT стороны' },
  { id: 8, map: 'Dust II', type: 'smoke', side: 'T', name: 'Long Doors Smoke', description: 'Помогает пройти Long' },
]

export default function CS2Grenades() {
  const accent = CS2_ACCENT
  const [selectedMap, setSelectedMap] = useState('Mirage')
  const [selectedType, setSelectedType] = useState(null)
  const [grenades, setGrenades] = useState(MOCK_GRENADES)
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    setLoading(true)
    cs2.getGrenades({ map: selectedMap })
      .then(data => { if (data?.length) setGrenades(data) })
      .catch(() => {}) // fallback to mock
      .finally(() => setLoading(false))
  }, [selectedMap])

  const filtered = grenades.filter(g =>
    g.map === selectedMap && (!selectedType || g.type === selectedType)
  )

  return (
    <Stack gap={16}>
      <Card pad={18} glow accent={accent} style={{ borderColor: `${accent}33` }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 16 }}>
          <Icon name="drop" size={20} color={accent} />
          <div>
            <div style={{ fontSize: 18, fontWeight: 800 }}>Grenade Library</div>
            <div style={{ fontSize: 12, color: GM.muted }}>Готовые позиции для всех карт CS2</div>
          </div>
        </div>

        {/* Map selector */}
        <div style={{ marginBottom: 12 }}>
          <Kicker style={{ marginBottom: 8, display: 'block' }}>Карта</Kicker>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
            {MAPS.map(m => (
              <button key={m} onClick={() => setSelectedMap(m)} style={{
                padding: '7px 14px', borderRadius: 6, border: 'none', cursor: 'pointer', fontFamily: 'inherit',
                fontWeight: 700, fontSize: 12.5,
                background: selectedMap === m ? accent : GM.surf,
                color: selectedMap === m ? GM.bg : GM.muted,
              }}>{m}</button>
            ))}
          </div>
        </div>

        {/* Type filter */}
        <div>
          <Kicker style={{ marginBottom: 8, display: 'block' }}>Тип</Kicker>
          <div style={{ display: 'flex', gap: 6 }}>
            <button onClick={() => setSelectedType(null)} style={{
              padding: '6px 12px', borderRadius: 6, border: 'none', cursor: 'pointer', fontFamily: 'inherit',
              fontWeight: 700, fontSize: 12, background: !selectedType ? accent : GM.surf, color: !selectedType ? GM.bg : GM.muted,
            }}>All</button>
            {GRENADE_TYPES.map(({ type, label, color }) => (
              <button key={type} onClick={() => setSelectedType(type === selectedType ? null : type)} style={{
                padding: '6px 12px', borderRadius: 6, cursor: 'pointer', fontFamily: 'inherit',
                fontWeight: 700, fontSize: 12,
                background: selectedType === type ? `${color}22` : GM.surf,
                color: selectedType === type ? color : GM.muted,
                border: selectedType === type ? `1px solid ${color}55` : `1px solid transparent`,
              }}>{label}</button>
            ))}
          </div>
        </div>
      </Card>

      {/* Grenades grid */}
      {loading ? (
        <div style={{ textAlign: 'center', padding: 40, color: GM.muted }}>Loading…</div>
      ) : filtered.length === 0 ? (
        <Card pad={40} style={{ textAlign: 'center' }}>
          <div style={{ fontSize: 14, color: GM.muted }}>Нет гранат для выбранных фильтров</div>
        </Card>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: 12 }}>
          {filtered.map(g => {
            const gType = GRENADE_TYPES.find(t => t.type === g.type)
            return (
              <Card key={g.id} pad={16} style={{ cursor: 'pointer', transition: 'border-color 0.15s', borderColor: GM.border }}
                onMouseEnter={e => e.currentTarget.style.borderColor = accent}
                onMouseLeave={e => e.currentTarget.style.borderColor = GM.border}
              >
                <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', marginBottom: 10 }}>
                  <div style={{ display: 'flex', gap: 8 }}>
                    <Badge color={gType?.color || accent}>{gType?.label || g.type}</Badge>
                    <Badge color={g.side === 'T' ? '#FF6B00' : '#4A90D9'}>{g.side} side</Badge>
                  </div>
                </div>
                <div style={{ fontSize: 14, fontWeight: 800, marginBottom: 6, lineHeight: 1.25 }}>{g.name}</div>
                <div style={{ fontSize: 12.5, color: GM.muted, lineHeight: 1.5 }}>{g.description}</div>
                <div style={{ marginTop: 12, padding: '10px 12px', background: GM.surf, borderRadius: 6, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                  <Mono style={{ fontSize: 10, color: GM.deep }}>Нажми для видео-инструкции</Mono>
                </div>
              </Card>
            )
          })}
        </div>
      )}

      {/* Add grenade CTA */}
      <Card pad={18} style={{ textAlign: 'center', border: `1px dashed ${GM.border}` }}>
        <div style={{ fontSize: 14, fontWeight: 700, marginBottom: 8 }}>Загрузи свою гранату</div>
        <div style={{ fontSize: 12, color: GM.muted, marginBottom: 14 }}>Импортируй гранату из CS2-рекордера или добавь вручную</div>
        <button style={{ padding: '10px 20px', borderRadius: 7, border: `1px solid ${accent}`, background: `${accent}16`, color: accent, fontWeight: 700, fontSize: 13, fontFamily: 'inherit', cursor: 'pointer' }}>
          + Добавить гранату
        </button>
      </Card>
    </Stack>
  )
}
