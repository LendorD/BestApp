import { useState } from 'react'
import { GM } from '../lib/theme.js'
import {
  Icon, Mono, Kicker, Badge, Delta, Avatar, Card, SectionTitle,
  AreaChart, Sparkline, Gauge, RadarChart, Meter, Stack, Cols,
} from './primitives.jsx'
import { heroIcon } from '../lib/dotaHeroImages.js'

// ── Period tabs ───────────────────────────────────────
export function PeriodTabs({ accent, period, setPeriod }) {
  return (
    <div style={{ display: 'flex', gap: 4, padding: 3, background: GM.card, border: `1px solid ${GM.border}`, borderRadius: 7 }}>
      {['7D', '30D', '90D'].map((p) => (
        <button key={p} onClick={() => setPeriod?.(p)} style={{
          border: 'none', cursor: 'pointer',
          fontFamily: "'JetBrains Mono', monospace", fontWeight: 600, fontSize: 11.5,
          padding: '6px 13px', borderRadius: 5,
          background: period === p ? accent : 'transparent',
          color: period === p ? GM.bg : GM.muted,
        }}>{p}</button>
      ))}
    </div>
  )
}

// ── Profile header ────────────────────────────────────
export function ProfileHeader({ d, accent, period, setPeriod }) {
  const p = d.player
  const form = d.matches.slice(0, 5).map((m) => m.result).join(' ')
  const mmrLabel = accent === '#FF6B00' ? 'ELO' : 'MMR'
  return (
    <Card glow accent={accent} pad={0} style={{ borderColor: `${accent}3a` }}>
      <div style={{ display: 'flex', alignItems: 'stretch', flexWrap: 'wrap' }}>
        <div style={{ flex: '1 1 420px', padding: 22, display: 'flex', gap: 18, alignItems: 'center' }}>
          <Avatar letter={p.avatar} accent={accent} size={76} />
          <div style={{ minWidth: 0 }}>
            <Kicker color={accent}>{p.seasonLabel}</Kicker>
            <div style={{ display: 'flex', alignItems: 'baseline', gap: 10, marginTop: 4 }}>
              <span style={{ fontSize: 26, fontWeight: 900, letterSpacing: '-0.02em' }}>{p.name}</span>
              <Mono style={{ fontSize: 12, color: GM.deep }}>#{p.accountId}</Mono>
            </div>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8, marginTop: 10 }}>
              <Badge color={accent}>{p.rankTier}</Badge>
              {p.mmr ? (
                <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6, fontSize: 12, color: GM.muted, fontWeight: 600 }}>
                  <Mono style={{ color: GM.text, fontWeight: 700 }}>{p.mmr}</Mono> {mmrLabel}
                  {p.mmrDelta ? <>{' · '}<Delta value={`+${p.mmrDelta}`} up /></> : null}
                </span>
              ) : null}
              {p.region ? <span style={{ fontSize: 12, color: GM.muted, fontWeight: 600 }}>{p.region}</span> : null}
              {p.rolesLine ? <span style={{ fontSize: 12, color: GM.muted, fontWeight: 600 }}>{p.rolesLine}</span> : null}
            </div>
          </div>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 22, padding: '0 24px', borderLeft: `1px solid ${GM.border}` }}>
          <div>
            <Kicker>Rank percentile</Kicker>
            <div style={{ fontSize: 18, fontWeight: 800, color: accent, marginTop: 4, fontFamily: "'JetBrains Mono', monospace" }}>{d.score.percentile}</div>
          </div>
          <div>
            <Kicker>Form (5g)</Kicker>
            <div style={{ fontSize: 18, fontWeight: 800, color: accent, marginTop: 4, fontFamily: "'JetBrains Mono', monospace" }}>{form}</div>
          </div>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', padding: '0 22px 0 0' }}>
          <PeriodTabs accent={accent} period={period} setPeriod={setPeriod} />
        </div>
      </div>
    </Card>
  )
}

// ── Score panel ───────────────────────────────────────
export function ScorePanel({ d, accent }) {
  const s = d.score
  return (
    <Card glow accent={accent} pad={20} style={{ height: '100%' }}>
      <SectionTitle title="GameMentor Score" sub={s.caption} right={s.delta ? <Delta value={`+${s.delta}`} up /> : null} />
      <div style={{ display: 'flex', gap: 22, alignItems: 'center', flexWrap: 'wrap' }}>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
          <Gauge value={s.value} accent={accent} size={156} />
          {s.percentile ? <Badge color={accent}>{s.percentile}</Badge> : null}
        </div>
        <div style={{ flex: 1, minWidth: 220, display: 'flex', flexDirection: 'column', gap: 10 }}>
          {s.breakdown.map((b) => (
            <div key={b.label}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 5 }}>
                <span style={{ fontSize: 12.5, fontWeight: 700, color: GM.text }}>{b.label}</span>
                <Mono style={{ fontSize: 12, color: b.value >= 75 ? accent : b.value < 62 ? GM.red : GM.muted, fontWeight: 700 }}>{b.value}</Mono>
              </div>
              <Meter value={b.value} accent={b.value < 62 ? GM.red : accent} glow={b.value >= 75} />
            </div>
          ))}
        </div>
      </div>
    </Card>
  )
}

// ── KPI grid ──────────────────────────────────────────
const KPI_ICON = {
  'Winrate': 'trophy', 'Win%': 'trophy',
  'KDA': 'sword', 'K/D': 'sword',
  'GPM': 'coin', 'XPM': 'spark',
  'Last hits': 'target', 'Last hits/10m': 'target',
  'Hero DMG': 'bolt', 'ADR': 'bolt', 'HS%': 'target',
  'Util DMG': 'drop', 'Clutch%': 'crown', 'Matches': 'grid', 'Wins': 'check',
}

export function KpiGrid({ d, accent, cols = 3 }) {
  return (
    <div style={{ display: 'grid', gridTemplateColumns: `repeat(${cols}, 1fr)`, gap: 12 }}>
      {d.kpis.map((k) => (
        <Card key={k.label} pad={14} style={{ minWidth: 0 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <span style={{ display: 'inline-flex', alignItems: 'center', gap: 7, minWidth: 0 }}>
              <span style={{ width: 24, height: 24, borderRadius: 6, background: `${accent}14`, border: `1px solid ${accent}33`, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                <Icon name={KPI_ICON[k.label] || 'graph'} size={13} color={accent} />
              </span>
              <Kicker>{k.label}</Kicker>
            </span>
            {k.delta ? <Delta value={k.delta} up={k.up} /> : null}
          </div>
          <div style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: 25, fontWeight: 700, color: GM.text, margin: '8px 0 4px', letterSpacing: '-0.01em' }}>{k.value}</div>
          <Sparkline data={k.spark} accent={k.up ? accent : GM.red} height={28} />
        </Card>
      ))}
    </div>
  )
}

// ── Trend chart ───────────────────────────────────────
export function TrendCard({ d, accent }) {
  const [mode, setMode] = useState('winrate')
  const data = mode === 'winrate' ? d.trend.winrate : d.trend.mmr
  const modeLabel = accent === '#FF6B00' ? 'Elo' : 'MMR'
  const last = data.length ? data[data.length - 1] : null
  return (
    <Card pad={18} style={{ height: '100%' }}>
      <SectionTitle
        title="Performance Trend"
        sub="Скользящее окно по матчам"
        right={
          <div style={{ display: 'flex', gap: 4, padding: 3, background: GM.bg, border: `1px solid ${GM.border}`, borderRadius: 7 }}>
            {[['winrate', 'Winrate'], ['mmr', modeLabel]].map(([m, lbl]) => (
              <button key={m} onClick={() => setMode(m)} style={{
                border: 'none', cursor: 'pointer',
                fontFamily: "'JetBrains Mono', monospace", fontWeight: 600, fontSize: 11,
                padding: '5px 11px', borderRadius: 5,
                background: mode === m ? accent : 'transparent',
                color: mode === m ? GM.bg : GM.muted,
              }}>{lbl}</button>
            ))}
          </div>
        }
      />
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 10, marginBottom: 8 }}>
        <span style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: 28, fontWeight: 700 }}>
          {last == null ? '—' : (mode === 'winrate' ? `${last}%` : last)}
        </span>
        <span style={{ fontSize: 12, color: GM.deep }}>{data.length ? `по ${data.length} матчам` : 'нет данных'}</span>
      </div>
      <AreaChart data={data} accent={accent} height={156} showDots />
    </Card>
  )
}

// ── Radar card ────────────────────────────────────────
export function RadarCard({ d, accent }) {
  return (
    <Card pad={18} style={{ height: '100%' }}>
      <SectionTitle title="Skill Profile" sub="Профиль навыков" />
      <RadarChart axes={d.radar.axes} you={d.radar.you} rankAvg={d.radar.rankAvg} accent={accent} size={236} />
      <div style={{ display: 'flex', justifyContent: 'center', gap: 18, marginTop: 6 }}>
        <span style={{ display: 'inline-flex', alignItems: 'center', gap: 7, fontSize: 11.5, color: GM.muted, fontWeight: 600 }}>
          <span style={{ width: 16, height: 0, borderTop: `2px solid ${accent}` }} /> You
        </span>
        {d.radar.rankAvg ? (
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 7, fontSize: 11.5, color: GM.muted, fontWeight: 600 }}>
            <span style={{ width: 16, height: 0, borderTop: `2px dashed ${GM.muted}` }} /> Rank avg
          </span>
        ) : null}
      </div>
    </Card>
  )
}

// ── AI Insights ───────────────────────────────────────
export function AiInsights({ d, accent }) {
  const map = { weak: GM.red, strong: accent, focus: GM.premium }
  return (
    <Card pad={18} glow accent={GM.premium} style={{ borderColor: `${GM.premium}33` }}>
      <SectionTitle
        title={<span style={{ display: 'inline-flex', alignItems: 'center', gap: 8 }}><Icon name="spark" size={17} color={GM.premium} /> AI Coach Insights</span>}
        sub="Generated from your last 100 matches"
        right={<Badge color={GM.premium}>◆ PRO</Badge>}
      />
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))', gap: 12 }}>
        {d.insights.map((it) => (
          <div key={it.title} style={{ background: GM.bg, border: `1px solid ${GM.border}`, borderLeft: `3px solid ${map[it.kind]}`, borderRadius: 7, padding: 14 }}>
            <Kicker color={map[it.kind]}>{it.tag}</Kicker>
            <div style={{ fontSize: 14, fontWeight: 800, margin: '8px 0 6px', lineHeight: 1.25 }}>{it.title}</div>
            <div style={{ fontSize: 12.5, color: GM.muted, lineHeight: 1.5 }}>{it.body}</div>
          </div>
        ))}
      </div>
      <button style={{
        marginTop: 14, width: '100%', border: `1px solid ${GM.premium}`,
        background: `${GM.premium}16`, color: GM.premium,
        fontWeight: 800, fontSize: 13, fontFamily: 'inherit',
        padding: '11px 0', borderRadius: 7, cursor: 'pointer',
        display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
      }}>
        <Icon name="bolt" size={15} color={GM.premium} /> Generate full AI report
      </button>
    </Card>
  )
}

// ── Matches table ─────────────────────────────────────
export function MatchesTable({ d, accent, rows = 6 }) {
  const isCs = accent === '#FF6B00'
  const cols = isCs
    ? '1.4fr 0.5fr 0.9fr 1fr 0.8fr 0.6fr'
    : '1.4fr 0.5fr 1fr 0.8fr 0.8fr 0.6fr'
  const headers = isCs
    ? ['Map', '', 'K/D/A', 'Score', 'ADR', 'Rating']
    : ['Hero', '', 'K/D/A', 'GPM', 'Duration', 'Impact']
  return (
    <Card pad={0} style={{ height: '100%' }}>
      <div style={{ padding: '16px 18px 12px' }}>
        <SectionTitle
          title="Recent Matches"
          sub={`Last ${d.matches.length} · ${isCs ? 'Premier' : 'Ranked'}`}
          right={<span style={{ fontSize: 12, color: accent, fontWeight: 700, cursor: 'pointer' }}>View all →</span>}
        />
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: cols, padding: '0 18px 8px', gap: 8 }}>
        {headers.map((h, i) => <Kicker key={i} style={{ textAlign: i > 1 ? 'right' : 'left' }}>{h}</Kicker>)}
      </div>
      {d.matches.slice(0, rows).map((m, i) => (
        <div key={i} style={{
          display: 'grid', gridTemplateColumns: cols, alignItems: 'center',
          gap: 8, padding: '10px 18px',
          borderTop: `1px solid ${GM.borderSoft}`, position: 'relative',
        }}>
          <div style={{ position: 'absolute', left: 0, top: 0, bottom: 0, width: 3, background: m.result === 'W' ? accent : GM.red, opacity: 0.7 }} />
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, minWidth: 0 }}>
            {m.heroId ? (
              <img src={heroIcon(m.heroId)} alt={m.hero} loading="lazy"
                onError={(e) => { e.currentTarget.style.visibility = 'hidden' }}
                style={{ width: 30, height: 30, borderRadius: 6, objectFit: 'cover', background: GM.surf, border: `1px solid ${GM.border}`, flexShrink: 0 }} />
            ) : (
              <div style={{
                width: 30, height: 30, borderRadius: 6, background: GM.surf,
                border: `1px solid ${GM.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontFamily: "'JetBrains Mono', monospace", fontSize: 11, fontWeight: 700, color: GM.muted, flexShrink: 0,
              }}>{m.hi}</div>
            )}
            <div style={{ minWidth: 0 }}>
              <div style={{ fontSize: 12.5, fontWeight: 700, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{m.hero}</div>
              <Mono style={{ fontSize: 10, color: GM.deep }}>{m.when} ago</Mono>
            </div>
          </div>
          <Mono style={{ fontWeight: 700, fontSize: 12, color: m.result === 'W' ? accent : GM.red }}>{m.result}</Mono>
          <Mono style={{ textAlign: 'right', fontSize: 12, color: GM.text }}>{m.kda}</Mono>
          <Mono style={{ textAlign: 'right', fontSize: 12, color: GM.muted }}>{isCs ? m.score : m.gpm}</Mono>
          <Mono style={{ textAlign: 'right', fontSize: 12, color: GM.muted }}>{m.dur}</Mono>
          <Mono style={{ textAlign: 'right', fontSize: 12, fontWeight: 700, color: m.impact >= (isCs ? 1.2 : 8) ? accent : GM.muted }}>{m.impact}</Mono>
        </div>
      ))}
    </Card>
  )
}

// ── Leaderboard ───────────────────────────────────────
export function LeaderboardCard({ d, accent }) {
  return (
    <Card pad={18} style={{ height: '100%' }}>
      <SectionTitle title="Pro Benchmark" sub={d.leaderboard.caption} />
      <div style={{ display: 'flex', flexDirection: 'column', gap: 7, marginBottom: 16 }}>
        {d.leaderboard.rows.map((r, i) => (
          <div key={r.name} style={{
            display: 'flex', alignItems: 'center', gap: 11, padding: '8px 11px', borderRadius: 7,
            background: r.you ? `${accent}14` : GM.bg,
            border: `1px solid ${r.you ? accent + '3a' : GM.border}`,
          }}>
            <Mono style={{ fontSize: 12, color: GM.deep, width: 16 }}>{i + 1}</Mono>
            <div style={{ width: 26, height: 26, borderRadius: 6, background: GM.surf, border: `1px solid ${GM.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 11, fontWeight: 800, color: r.you ? accent : GM.muted }}>{r.name[0]}</div>
            <span style={{ flex: 1, fontSize: 13, fontWeight: r.you ? 800 : 600, color: r.you ? GM.text : GM.muted }}>
              {r.name}{r.you && <Mono style={{ color: accent, marginLeft: 6, fontSize: 10 }}> YOU</Mono>}
            </span>
            <Mono style={{ fontSize: 13, fontWeight: 700, color: r.you ? accent : GM.text }}>{r.score}</Mono>
          </div>
        ))}
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 11 }}>
        {d.leaderboard.bars.map((b) => (
          <div key={b.label}>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 5 }}>
              <span style={{ fontSize: 11.5, fontWeight: 700, color: GM.muted }}>{b.label}</span>
              <Mono style={{ fontSize: 11, color: GM.deep }}>{b.you} / <span style={{ color: GM.premium }}>{b.pro}</span></Mono>
            </div>
            <div style={{ position: 'relative', height: 6, background: GM.surf, borderRadius: 999 }}>
              <div style={{ position: 'absolute', left: 0, top: 0, bottom: 0, width: `${b.pro}%`, background: `${GM.premium}40`, borderRadius: 999 }} />
              <div style={{ position: 'absolute', left: 0, top: 0, bottom: 0, width: `${b.you}%`, background: accent, borderRadius: 999 }} />
            </div>
          </div>
        ))}
      </div>
    </Card>
  )
}

// ── Training goals ────────────────────────────────────
export function TrainingGoals({ d, accent }) {
  return (
    <Card pad={18}>
      <SectionTitle
        title={<span style={{ display: 'inline-flex', alignItems: 'center', gap: 8 }}><Icon name="target" size={17} color={accent} /> Training Goals</span>}
        sub="Weekly improvement plan"
        right={<Mono style={{ fontSize: 11, color: GM.deep }}>3 ACTIVE</Mono>}
      />
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: 12 }}>
        {d.goals.map((g) => (
          <div key={g.label} style={{ background: GM.bg, border: `1px solid ${GM.border}`, borderRadius: 7, padding: 14 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 8, marginBottom: 10 }}>
              <span style={{ fontSize: 12.5, fontWeight: 700, lineHeight: 1.3 }}>{g.label}</span>
              <Mono style={{ fontSize: 14, fontWeight: 700, color: accent }}>{g.pct}%</Mono>
            </div>
            <Meter value={g.pct} accent={accent} glow />
            <Mono style={{ fontSize: 10.5, color: GM.deep, marginTop: 8, display: 'block' }}>{g.sub}</Mono>
          </div>
        ))}
      </div>
    </Card>
  )
}
