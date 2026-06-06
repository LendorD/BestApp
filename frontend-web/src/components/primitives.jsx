import { GM } from '../lib/theme.js'

// ── Icon ─────────────────────────────────────────────
const PATHS = {
  grid:    'M3 3h7v7H3zM14 3h7v7h-7zM3 14h7v7H3zM14 14h7v7h-7z',
  user:    'M12 12a4 4 0 100-8 4 4 0 000 8zM5 20c0-3.3 3.1-5 7-5s7 1.7 7 5',
  spark:   'M12 3v4M12 17v4M3 12h4M17 12h4M6 6l2.5 2.5M15.5 15.5L18 18M18 6l-2.5 2.5M8.5 15.5L6 18',
  search:  'M11 11m-7 0a7 7 0 1014 0 7 7 0 10-14 0M20 20l-4-4',
  cube:    'M12 3l8 4.5v9L12 21l-8-4.5v-9zM12 3v18M4 7.5l8 4.5 8-4.5',
  target:  'M12 12m-9 0a9 9 0 1018 0 9 9 0 10-18 0M12 12m-4.5 0a4.5 4.5 0 109 0 4.5 4.5 0 10-9 0M12 12h.01',
  graph:   'M3 3v18h18M7 14l3-4 3 2 4-6',
  crown:   'M4 18h16M4 18l-1.5-9 5 3.5L12 5l4.5 7.5 5-3.5L20 18',
  pin:     'M12 21s7-6 7-11a7 7 0 10-14 0c0 5 7 11 7 11zM12 10m-2 0a2 2 0 104 0 2 2 0 10-4 0',
  drop:    'M12 3s6 7 6 11a6 6 0 11-12 0c0-4 6-11 6-11z',
  squares: 'M3 3h8v8H3zM13 3h8v8h-8zM3 13h8v8H3zM13 13h8v8h-8z',
  bolt:    'M13 2L4 14h7l-1 8 9-12h-7l1-8z',
  bell:    'M18 8a6 6 0 10-12 0c0 7-3 9-3 9h18s-3-2-3-9M13.7 21a2 2 0 01-3.4 0',
  gear:    'M12 15a3 3 0 100-6 3 3 0 000 6zM19.4 15a1.6 1.6 0 00.3 1.8l.1.1a2 2 0 11-2.8 2.8l-.1-.1a1.6 1.6 0 00-2.7 1.1V21a2 2 0 01-4 0v-.1A1.6 1.6 0 005 19.4l-.1.1a2 2 0 11-2.8-2.8l.1-.1A1.6 1.6 0 003.3 14H3a2 2 0 010-4h.1A1.6 1.6 0 004.6 8L4.5 8a2 2 0 112.8-2.8l.1.1A1.6 1.6 0 0010 4.6V4a2 2 0 014 0v.1A1.6 1.6 0 0016.7 6l.1-.1a2 2 0 112.8 2.8l-.1.1a1.6 1.6 0 00-.3 1.8 1.6 1.6 0 001.5 1H21a2 2 0 010 4h-.1a1.6 1.6 0 00-1.5 1z',
  back:    'M19 12H5M5 12l7-7M5 12l7 7',
  refresh: 'M23 4v6h-6M1 20v-6h6M3.51 9a9 9 0 0114.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0020.49 15',
  check:   'M20 6L9 17l-5-5',
  coin:    'M12 3a9 9 0 100 18 9 9 0 000-18zM9.8 9.2A2.2 2.2 0 0112 7.8c1.2 0 2 .7 2 1.6 0 2-3.9 1.3-3.9 3.4 0 .9.9 1.6 2.1 1.6a2.2 2.2 0 002.1-1.4M12 6.3v1.5M12 14.7v1.5',
  sword:   'M14.5 17.5L4 7V4h3l10.5 10.5M13 19l3-3M15 17l4 4M18.5 20.5l2-2',
  trophy:  'M8 21h8M12 17.5V21M6 4h12v5a6 6 0 01-12 0V4zM6 6H4v1a3 3 0 003 3M18 6h2v1a3 3 0 01-3 3',
  sun:     'M12 17a5 5 0 100-10 5 5 0 000 10zM12 1v3M12 20v3M4.2 4.2l2.1 2.1M17.7 17.7l2.1 2.1M1 12h3M20 12h3M4.2 19.8l2.1-2.1M17.7 6.3l2.1-2.1',
  moon:    'M21 12.8A9 9 0 1111.2 3a7 7 0 009.8 9.8z',
}

export function Icon({ name, size = 18, color = 'currentColor', sw = 1.6 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round">
      <path d={PATHS[name] || PATHS.grid} />
    </svg>
  )
}

// ── Typography atoms ──────────────────────────────────
export function Mono({ children, style }) {
  return <span style={{ fontFamily: "'JetBrains Mono', monospace", ...style }}>{children}</span>
}

export function Kicker({ children, color, style }) {
  return (
    <span style={{
      fontFamily: "'JetBrains Mono', monospace",
      fontSize: 10.5, fontWeight: 600,
      letterSpacing: '0.18em', textTransform: 'uppercase',
      color: color || GM.deep, ...style,
    }}>
      {children}
    </span>
  )
}

export function Badge({ children, color, solid }) {
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      fontFamily: "'JetBrains Mono', monospace",
      fontSize: 10.5, fontWeight: 600, letterSpacing: '0.08em',
      padding: '5px 9px', borderRadius: 5,
      color: solid ? GM.bg : color,
      background: solid ? color : `${color}16`,
      border: `1px solid ${solid ? color : color + '44'}`,
    }}>
      {children}
    </span>
  )
}

export function Delta({ value, up }) {
  const col = up ? '#00D084' : GM.red
  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 3, fontFamily: "'JetBrains Mono', monospace", fontSize: 11, fontWeight: 600, color: col }}>
      <span style={{ fontSize: 9 }}>{up ? '▲' : '▼'}</span>
      {value}
    </span>
  )
}

export function Avatar({ letter, accent, size = 56 }) {
  return (
    <div style={{
      width: size, height: size, borderRadius: 8, flexShrink: 0,
      background: `linear-gradient(150deg, ${GM.surf}, ${GM.bg})`,
      border: `1px solid ${accent}`,
      boxShadow: `0 0 0 3px ${accent}1c`,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      fontSize: size * 0.42, fontWeight: 900, color: accent, letterSpacing: '-0.02em',
    }}>
      {letter}
    </div>
  )
}

// ── Card ──────────────────────────────────────────────
export function Card({ children, accent, glow, pad = 18, style }) {
  return (
    <div style={{
      position: 'relative', background: GM.card,
      border: `1px solid ${GM.border}`, borderRadius: 8, padding: pad,
      boxShadow: '0 1px 0 0 rgba(255,255,255,0.03) inset, 0 18px 40px -28px rgba(0,0,0,0.9)',
      overflow: 'hidden', ...style,
    }}>
      {glow && (
        <div style={{
          position: 'absolute', top: -60, right: -40, width: 220, height: 220,
          background: `radial-gradient(circle, ${accent}22 0%, transparent 65%)`,
          pointerEvents: 'none',
        }} />
      )}
      {children}
    </div>
  )
}

export function SectionTitle({ title, sub, right }) {
  return (
    <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', marginBottom: 14, gap: 12 }}>
      <div>
        <div style={{ fontSize: 15, fontWeight: 800, letterSpacing: '-0.01em', color: GM.text }}>{title}</div>
        {sub && <div style={{ fontSize: 12, color: GM.muted, marginTop: 2 }}>{sub}</div>}
      </div>
      {right}
    </div>
  )
}

// ── Charts ────────────────────────────────────────────
export function AreaChart({ data, accent, height = 150, showDots = false }) {
  if (!data || data.length < 2) return null
  const w = 560, h = height
  const pad = { l: 6, r: 6, t: 12, b: 10 }
  const min = Math.min(...data), max = Math.max(...data)
  const range = max - min || 1
  const ix = (i) => pad.l + (i / (data.length - 1)) * (w - pad.l - pad.r)
  const iy = (v) => pad.t + (1 - (v - min) / range) * (h - pad.t - pad.b)
  const pts = data.map((v, i) => [ix(i), iy(v)])
  const line = pts.map((p, i) => `${i ? 'L' : 'M'}${p[0].toFixed(1)} ${p[1].toFixed(1)}`).join(' ')
  const area = `${line} L${pts[pts.length - 1][0].toFixed(1)} ${h - pad.b} L${pts[0][0].toFixed(1)} ${h - pad.b} Z`
  const gid = `g${Math.random().toString(36).slice(2, 8)}`
  return (
    <svg viewBox={`0 0 ${w} ${h}`} width="100%" height={h} preserveAspectRatio="none" style={{ display: 'block' }}>
      <defs>
        <linearGradient id={gid} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor={accent} stopOpacity="0.28" />
          <stop offset="100%" stopColor={accent} stopOpacity="0" />
        </linearGradient>
      </defs>
      {[0.25, 0.5, 0.75].map((g) => (
        <line key={g} x1={pad.l} x2={w - pad.r}
          y1={pad.t + g * (h - pad.t - pad.b)} y2={pad.t + g * (h - pad.t - pad.b)}
          stroke={GM.border} strokeWidth="1" strokeDasharray="2 4" />
      ))}
      <path d={area} fill={`url(#${gid})`} />
      <path d={line} fill="none" stroke={accent} strokeWidth="2" strokeLinejoin="round" strokeLinecap="round" />
      {showDots && pts.map((p, i) => i === pts.length - 1 && (
        <circle key={i} cx={p[0]} cy={p[1]} r="3.5" fill={accent} stroke={GM.bg} strokeWidth="2" />
      ))}
    </svg>
  )
}

export function Sparkline({ data, accent, height = 34 }) {
  if (!data || data.length < 2) return null
  const w = 120, h = height
  const min = Math.min(...data), max = Math.max(...data)
  const range = max - min || 1
  const ix = (i) => (i / (data.length - 1)) * w
  const iy = (v) => 4 + (1 - (v - min) / range) * (h - 8)
  const line = data.map((v, i) => `${i ? 'L' : 'M'}${ix(i).toFixed(1)} ${iy(v).toFixed(1)}`).join(' ')
  return (
    <svg viewBox={`0 0 ${w} ${h}`} width="100%" height={h} preserveAspectRatio="none" style={{ display: 'block' }}>
      <path d={line} fill="none" stroke={accent} strokeWidth="1.6" strokeLinejoin="round" strokeLinecap="round" opacity="0.85" />
    </svg>
  )
}

export function Gauge({ value, accent, size = 168, stroke = 12 }) {
  const r = (size - stroke) / 2 - 2
  const cx = size / 2, cy = size / 2
  const START = 135, SWEEP = 270
  const polar = (deg) => {
    const a = ((deg - 90) * Math.PI) / 180
    return [cx + r * Math.cos(a), cy + r * Math.sin(a)]
  }
  const arc = (fromDeg, toDeg) => {
    const s = polar(toDeg), e = polar(fromDeg)
    const large = toDeg - fromDeg <= 180 ? 0 : 1
    return `M${s[0].toFixed(1)} ${s[1].toFixed(1)} A${r} ${r} 0 ${large} 0 ${e[0].toFixed(1)} ${e[1].toFixed(1)}`
  }
  const progEnd = START + SWEEP * (value / 100)
  return (
    <div style={{ position: 'relative', width: size, height: size }}>
      <svg width={size} height={size}>
        <path d={arc(START, START + SWEEP)} fill="none" stroke={GM.surf} strokeWidth={stroke} strokeLinecap="round" />
        <path d={arc(START, progEnd)} fill="none" stroke={accent} strokeWidth={stroke} strokeLinecap="round"
          style={{ filter: `drop-shadow(0 0 6px ${accent}66)` }} />
      </svg>
      <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 2 }}>
        <div style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: size * 0.3, fontWeight: 700, color: GM.text, lineHeight: 1 }}>{value}</div>
        <div style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: 9.5, letterSpacing: '0.12em', color: GM.deep }}>/ 100</div>
      </div>
    </div>
  )
}

export function RadarChart({ axes, you, rankAvg, accent, size = 230 }) {
  const cx = size / 2, cy = size / 2
  const R = size / 2 - 26
  const n = axes.length
  const pt = (i, frac) => {
    const ang = (Math.PI * 2 * i) / n - Math.PI / 2
    return [cx + Math.cos(ang) * R * frac, cy + Math.sin(ang) * R * frac]
  }
  const poly = (vals) => vals.map((v, i) => pt(i, v / 100).join(',')).join(' ')
  return (
    <svg width="100%" height={size} viewBox={`0 0 ${size} ${size}`} style={{ display: 'block' }}>
      {[0.25, 0.5, 0.75, 1].map((g) => (
        <polygon key={g} points={axes.map((_, i) => pt(i, g).join(',')).join(' ')} fill="none" stroke={GM.border} strokeWidth="1" />
      ))}
      {axes.map((_, i) => {
        const p = pt(i, 1)
        return <line key={i} x1={cx} y1={cy} x2={p[0]} y2={p[1]} stroke={GM.border} strokeWidth="1" />
      })}
      {rankAvg && rankAvg.length ? <polygon points={poly(rankAvg)} fill="rgba(138,148,166,0.10)" stroke={GM.muted} strokeWidth="1.2" strokeDasharray="3 3" /> : null}
      <polygon points={poly(you)} fill={`${accent}22`} stroke={accent} strokeWidth="2" />
      {you.map((v, i) => {
        const p = pt(i, v / 100)
        return <circle key={i} cx={p[0]} cy={p[1]} r="2.6" fill={accent} />
      })}
      {axes.map((label, i) => {
        const p = pt(i, 1.18)
        return (
          <text key={i} x={p[0]} y={p[1]} fill={GM.muted} fontSize="9.5"
            fontFamily="'JetBrains Mono', monospace" textAnchor="middle" dominantBaseline="middle" letterSpacing="0.04em">
            {label.toUpperCase()}
          </text>
        )
      })}
    </svg>
  )
}

export function Meter({ value, accent, height = 6, glow }) {
  return (
    <div style={{ width: '100%', height, background: GM.surf, borderRadius: 999, overflow: 'hidden' }}>
      <div style={{ width: `${value}%`, height: '100%', background: accent, borderRadius: 999, boxShadow: glow ? `0 0 8px ${accent}88` : 'none' }} />
    </div>
  )
}

// Layout helpers
export function Stack({ children, gap = 16, style }) {
  return <div style={{ display: 'flex', flexDirection: 'column', gap, ...style }}>{children}</div>
}

export function Cols({ children, t, gap = 16, align = 'stretch', style }) {
  return <div style={{ display: 'grid', gridTemplateColumns: t, gap, alignItems: align, ...style }}>{children}</div>
}
