import { useState, useEffect } from 'react'
import { GM } from '../lib/theme.js'
import { Card, Kicker, Mono, SectionTitle } from './primitives.jsx'
import { dota } from '../lib/api.js'

// Real OpenDota account IDs of well-known pros, grouped by role.
// Note: some pros hide their match history, then their line will be empty.
const PROS = {
  'Carry': [
    { id: '321580662', name: 'Yatoro' },
    { id: '86745912',  name: 'Arteezy' },
    { id: '116585378', name: 'Ame' },
    { id: '311360822', name: '23savage' },
  ],
  'Mid': [
    { id: '111620041', name: 'SumaiL' },
    { id: '94054712',  name: 'Topson' },
    { id: '105248644', name: 'Miracle-' },
    { id: '175258197', name: 'Nisha' },
  ],
  'Offlane': [
    { id: '113331514', name: 'Collapse' },
    { id: '94155156',  name: 'BOOM-era' },
    { id: '177416702', name: 'Zai' },
    { id: '88271237',  name: 'MinD_ContRoL' },
  ],
  'Support': [
    { id: '87278757',  name: 'Puppey' },
    { id: '86738694',  name: 'Cr1t-' },
    { id: '70388657',  name: 'Dendi' },
    { id: '82262664',  name: 'Fly' },
  ],
}

const PALETTE = ['#D4AF37', '#4A90D9', '#B36BFF', '#FF6B00', '#34D399']

function seriesFromDash(raw) {
  const fm = (raw && raw.form_timeline && raw.form_timeline.matches) || []
  let won = 0
  const winrate = []
  fm.forEach((m, i) => { if (m.won) won++; winrate.push(Math.round((won / (i + 1)) * 100)) })
  const ms = (raw && raw.matches) || []
  const gpm = [...ms].reverse().map(m => m.gold_per_min || 0)
  return { winrate, gpm }
}

function MultiLine({ lines, metric, height = 210 }) {
  const usable = lines.filter(l => l.points && l.points.length >= 2)
  const all = usable.flatMap(l => l.points)
  if (all.length < 2) {
    return <div style={{ padding: 40, textAlign: 'center', color: GM.muted, fontSize: 13 }}>Нет данных для графика (у выбранных игроков может быть скрыта история матчей)</div>
  }
  const w = 640, h = height, pad = { l: 30, r: 10, t: 14, b: 16 }
  const min = Math.min(...all), max = Math.max(...all), range = max - min || 1
  const ix = (i, len) => pad.l + (len <= 1 ? 0 : (i / (len - 1)) * (w - pad.l - pad.r))
  const iy = (v) => pad.t + (1 - (v - min) / range) * (h - pad.t - pad.b)
  const suffix = metric === 'winrate' ? '%' : ''
  return (
    <svg viewBox={`0 0 ${w} ${h}`} width="100%" height={h} style={{ display: 'block' }}>
      {[0, 0.25, 0.5, 0.75, 1].map((g) => {
        const y = pad.t + g * (h - pad.t - pad.b)
        const val = Math.round(max - g * range)
        return (
          <g key={g}>
            <line x1={pad.l} x2={w - pad.r} y1={y} y2={y} stroke={GM.border} strokeWidth="1" strokeDasharray="2 4" />
            <text x={2} y={y + 3} fill={GM.deep} fontSize="9" fontFamily="'JetBrains Mono', monospace">{val}{suffix}</text>
          </g>
        )
      })}
      {usable.map((l) => {
        const pts = l.points.map((v, i) => [ix(i, l.points.length), iy(v)])
        const d = pts.map((p, i) => `${i ? 'L' : 'M'}${p[0].toFixed(1)} ${p[1].toFixed(1)}`).join(' ')
        return (
          <g key={l.id}>
            <path d={d} fill="none" stroke={l.color} strokeWidth={l.you ? 2.6 : 1.8}
              strokeLinejoin="round" strokeLinecap="round" strokeDasharray={l.you ? '0' : '5 4'}
              style={{ filter: l.you ? `drop-shadow(0 0 5px ${l.color}66)` : 'none' }} />
            {l.you && <circle cx={pts[pts.length - 1][0]} cy={pts[pts.length - 1][1]} r="3.5" fill={l.color} stroke={GM.bg} strokeWidth="2" />}
          </g>
        )
      })}
    </svg>
  )
}

export default function ProCompare({ steamId, accent }) {
  const [role, setRole] = useState('Carry')
  const [metric, setMetric] = useState('winrate')
  const [enabled, setEnabled] = useState({})       // proId -> true
  const [cache, setCache] = useState({})           // id -> { winrate, gpm } | 'loading' | 'error'

  // Always load the user's own series.
  useEffect(() => {
    if (!steamId || cache[steamId]) return
    setCache(c => ({ ...c, [steamId]: 'loading' }))
    dota.getDashboard(steamId)
      .then(raw => setCache(c => ({ ...c, [steamId]: seriesFromDash(raw) })))
      .catch(() => setCache(c => ({ ...c, [steamId]: 'error' })))
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [steamId])

  const togglePro = (id) => {
    setEnabled(e => ({ ...e, [id]: !e[id] }))
    if (!cache[id]) {
      setCache(c => ({ ...c, [id]: 'loading' }))
      dota.getDashboard(id)
        .then(raw => setCache(c => ({ ...c, [id]: seriesFromDash(raw) })))
        .catch(() => setCache(c => ({ ...c, [id]: 'error' })))
    }
  }

  const seriesOf = (id) => {
    const v = cache[id]
    return v && v !== 'loading' && v !== 'error' ? (v[metric] || []) : []
  }

  const enabledPros = PROS[role].filter(p => enabled[p.id])
  const lines = [
    { id: steamId, name: 'Вы', color: accent, you: true, points: seriesOf(steamId) },
    ...enabledPros.map((p, i) => ({ id: p.id, name: p.name, color: PALETTE[i % PALETTE.length], points: seriesOf(p.id) })),
  ]

  return (
    <Card pad={18}>
      <SectionTitle
        title="Сравнение с про-игроками"
        sub="Твоя линия против топ-про по выбранной роли (реальные данные OpenDota)"
        right={
          <div style={{ display: 'flex', gap: 4, padding: 3, background: GM.bg, border: `1px solid ${GM.border}`, borderRadius: 7 }}>
            {[['winrate', 'Winrate'], ['gpm', 'GPM']].map(([m, lbl]) => (
              <button key={m} onClick={() => setMetric(m)} style={{
                border: 'none', cursor: 'pointer', fontFamily: "'JetBrains Mono', monospace",
                fontWeight: 600, fontSize: 11, padding: '5px 11px', borderRadius: 5,
                background: metric === m ? accent : 'transparent', color: metric === m ? GM.bg : GM.muted,
              }}>{lbl}</button>
            ))}
          </div>
        }
      />

      {/* Role tabs */}
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, marginBottom: 12 }}>
        {Object.keys(PROS).map(r => (
          <button key={r} onClick={() => setRole(r)} style={{
            padding: '7px 14px', borderRadius: 6, border: 'none', cursor: 'pointer', fontFamily: 'inherit',
            fontWeight: 700, fontSize: 12.5,
            background: role === r ? accent : GM.surf, color: role === r ? GM.bg : GM.muted,
          }}>{r}</button>
        ))}
      </div>

      {/* Pro chips (4 per role) */}
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8, marginBottom: 14 }}>
        {PROS[role].map((p, i) => {
          const on = !!enabled[p.id]
          const col = PALETTE[i % PALETTE.length]
          const st = cache[p.id]
          return (
            <button key={p.id} onClick={() => togglePro(p.id)} style={{
              display: 'inline-flex', alignItems: 'center', gap: 8,
              padding: '8px 12px', borderRadius: 8, cursor: 'pointer', fontFamily: 'inherit',
              fontWeight: 700, fontSize: 12.5,
              background: on ? `${col}1c` : GM.surf,
              color: on ? GM.text : GM.muted,
              border: `1px solid ${on ? col : GM.border}`,
            }}>
              <span style={{ width: 9, height: 9, borderRadius: 999, background: on ? col : GM.deep }} />
              {p.name}
              {st === 'loading' && <Mono style={{ fontSize: 10, color: GM.deep }}>…</Mono>}
              {st === 'error' && <Mono style={{ fontSize: 10, color: GM.red }}>скрыт</Mono>}
            </button>
          )
        })}
      </div>

      <MultiLine lines={lines} metric={metric} />

      {/* Legend */}
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: 16, marginTop: 8, justifyContent: 'center' }}>
        {lines.filter(l => l.points && l.points.length >= 2).map(l => (
          <span key={l.id} style={{ display: 'inline-flex', alignItems: 'center', gap: 7, fontSize: 11.5, color: GM.muted, fontWeight: 600 }}>
            <span style={{ width: 16, height: 0, borderTop: `2px ${l.you ? 'solid' : 'dashed'} ${l.color}` }} />
            {l.name}
          </span>
        ))}
      </div>
    </Card>
  )
}
