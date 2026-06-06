import { useState } from 'react'
import { GM, CS2_ACCENT } from '../lib/theme.js'
import { Card, Kicker, Badge, Icon, Mono, Stack, SectionTitle } from '../components/primitives.jsx'

const SETS = [
  { map: 'Mirage', side: 'T', name: 'A Execute (default)', items: ['Window smoke', 'Stairs smoke', 'CT smoke', 'A ramp flash'], difficulty: 'Easy' },
  { map: 'Mirage', side: 'T', name: 'B Rush', items: ['Market smoke', 'Short flash', 'Bench molotov'], difficulty: 'Medium' },
  { map: 'Inferno', side: 'T', name: 'Banana Control', items: ['Banana smoke', 'CT flash', 'Car molotov'], difficulty: 'Easy' },
  { map: 'Inferno', side: 'T', name: 'A Split', items: ['Pit smoke', 'Library smoke', 'Arch flash', 'Graveyard molotov'], difficulty: 'Hard' },
  { map: 'Nuke', side: 'T', name: 'Outside Take', items: ['Heaven smoke', 'Silo flash', 'Ramp molotov'], difficulty: 'Medium' },
  { map: 'Dust II', side: 'T', name: 'Long Push', items: ['Long doors smoke', 'Corner flash', 'Pit molotov'], difficulty: 'Easy' },
]
const DIFF_COLOR = { Easy: '#00D084', Medium: '#D4AF37', Hard: '#FF4D61' }

export default function UtilitySets() {
  const accent = CS2_ACCENT
  const maps = ['All', ...Array.from(new Set(SETS.map(s => s.map)))]
  const [map, setMap] = useState('All')
  const filtered = map === 'All' ? SETS : SETS.filter(s => s.map === map)

  return (
    <Stack gap={16}>
      <Card glow accent={accent} pad={20} style={{ borderColor: `${accent}33` }}>
        <SectionTitle
          title={<span style={{ display: 'inline-flex', alignItems: 'center', gap: 8 }}><Icon name="squares" size={18} color={accent} /> Utility Sets</span>}
          sub="Готовые связки гранат под исполнения"
          right={<Badge color={accent}>{SETS.length} сетов</Badge>}
        />
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, marginTop: 14 }}>
          {maps.map(m => (
            <button key={m} onClick={() => setMap(m)} style={{
              padding: '7px 14px', borderRadius: 6, border: 'none', cursor: 'pointer', fontFamily: 'inherit',
              fontWeight: 700, fontSize: 12.5,
              background: map === m ? accent : GM.surf, color: map === m ? GM.bg : GM.muted,
            }}>{m}</button>
          ))}
        </div>
      </Card>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: 12 }}>
        {filtered.map(s => (
          <Card key={s.map + s.name} pad={16}>
            <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 8, marginBottom: 12 }}>
              <div>
                <div style={{ fontSize: 14, fontWeight: 800, lineHeight: 1.25 }}>{s.name}</div>
                <Mono style={{ fontSize: 10.5, color: GM.deep }}>{s.map} · {s.side} side</Mono>
              </div>
              <Badge color={DIFF_COLOR[s.difficulty]}>{s.difficulty}</Badge>
            </div>
            <Stack gap={7}>
              {s.items.map((it, i) => (
                <div key={it} style={{ display: 'flex', alignItems: 'center', gap: 9, fontSize: 12.5, color: GM.text }}>
                  <span style={{ width: 18, height: 18, borderRadius: 5, background: GM.surf, border: `1px solid ${GM.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: "'JetBrains Mono', monospace", fontSize: 9.5, color: accent, flexShrink: 0 }}>{i + 1}</span>
                  {it}
                </div>
              ))}
            </Stack>
          </Card>
        ))}
      </div>
    </Stack>
  )
}
