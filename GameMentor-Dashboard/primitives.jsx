/* GameMentor — UI primitives & SVG charts. Exports to window. */

const GM = {
  bg: "#050608",
  card: "#0B0E13",
  surf: "#10141B",
  border: "#1B2430",
  borderSoft: "rgba(27,36,48,0.6)",
  text: "#F4F6FA",
  muted: "#8A94A6",
  deep: "#5A6475",
  premium: "#D4AF37",
  red: "#FF4D61",
};

/* ---------- tiny atoms ---------- */

function Mono({ children, style }) {
  return (
    <span style={{ fontFamily: "'JetBrains Mono', monospace", ...style }}>{children}</span>
  );
}

function Kicker({ children, color, style }) {
  return (
    <span
      style={{
        fontFamily: "'JetBrains Mono', monospace",
        fontSize: 10.5,
        fontWeight: 600,
        letterSpacing: "0.18em",
        textTransform: "uppercase",
        color: color || GM.deep,
        ...style,
      }}
    >
      {children}
    </span>
  );
}

function Card({ children, accent, glow, pad = 18, style, className }) {
  return (
    <div
      className={className}
      style={{
        position: "relative",
        background: GM.card,
        border: `1px solid ${GM.border}`,
        borderRadius: 8,
        padding: pad,
        boxShadow:
          "0 1px 0 0 rgba(255,255,255,0.03) inset, 0 18px 40px -28px rgba(0,0,0,0.9)",
        overflow: "hidden",
        ...style,
      }}
    >
      {glow && (
        <div
          style={{
            position: "absolute",
            top: -60,
            right: -40,
            width: 220,
            height: 220,
            background: `radial-gradient(circle, ${accent}22 0%, transparent 65%)`,
            pointerEvents: "none",
          }}
        />
      )}
      {children}
    </div>
  );
}

function SectionTitle({ title, sub, right }) {
  return (
    <div style={{ display: "flex", alignItems: "flex-end", justifyContent: "space-between", marginBottom: 14, gap: 12 }}>
      <div>
        <div style={{ fontSize: 15, fontWeight: 800, letterSpacing: "-0.01em", color: GM.text }}>{title}</div>
        {sub && <div style={{ fontSize: 12, color: GM.muted, marginTop: 2 }}>{sub}</div>}
      </div>
      {right}
    </div>
  );
}

function Badge({ children, color, solid }) {
  return (
    <span
      style={{
        display: "inline-flex",
        alignItems: "center",
        gap: 6,
        fontFamily: "'JetBrains Mono', monospace",
        fontSize: 10.5,
        fontWeight: 600,
        letterSpacing: "0.08em",
        padding: "5px 9px",
        borderRadius: 5,
        color: solid ? GM.bg : color,
        background: solid ? color : `${color}16`,
        border: `1px solid ${solid ? color : color + "44"}`,
      }}
    >
      {children}
    </span>
  );
}

function Delta({ value, up }) {
  const c = up ? GM.dotaFallback || "#00D084" : GM.red;
  const col = up ? "#00D084" : GM.red;
  return (
    <span style={{ display: "inline-flex", alignItems: "center", gap: 3, fontFamily: "'JetBrains Mono', monospace", fontSize: 11, fontWeight: 600, color: col }}>
      <span style={{ fontSize: 9 }}>{up ? "▲" : "▼"}</span>
      {value}
    </span>
  );
}

function Avatar({ letter, accent, size = 56, rank }) {
  return (
    <div style={{ position: "relative", width: size, height: size, flexShrink: 0 }}>
      <div
        style={{
          width: size,
          height: size,
          borderRadius: 8,
          background: `linear-gradient(150deg, ${GM.surf}, ${GM.bg})`,
          border: `1px solid ${accent}`,
          boxShadow: `0 0 0 3px ${accent}1c`,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          fontSize: size * 0.42,
          fontWeight: 900,
          color: accent,
          letterSpacing: "-0.02em",
        }}
      >
        {letter}
      </div>
    </div>
  );
}

/* ---------- charts ---------- */

// area + line chart
function AreaChart({ data, accent, width = 560, height = 150, fill = true, showDots = false }) {
  const pad = { l: 6, r: 6, t: 12, b: 10 };
  const w = width, h = height;
  const min = Math.min(...data), max = Math.max(...data);
  const range = max - min || 1;
  const ix = (i) => pad.l + (i / (data.length - 1)) * (w - pad.l - pad.r);
  const iy = (v) => pad.t + (1 - (v - min) / range) * (h - pad.t - pad.b);
  const pts = data.map((v, i) => [ix(i), iy(v)]);
  const line = pts.map((p, i) => `${i ? "L" : "M"}${p[0].toFixed(1)} ${p[1].toFixed(1)}`).join(" ");
  const area = `${line} L${pts[pts.length - 1][0].toFixed(1)} ${h - pad.b} L${pts[0][0].toFixed(1)} ${h - pad.b} Z`;
  const gid = "g" + Math.random().toString(36).slice(2, 8);
  return (
    <svg viewBox={`0 0 ${w} ${h}`} width="100%" height={h} preserveAspectRatio="none" style={{ display: "block" }}>
      <defs>
        <linearGradient id={gid} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor={accent} stopOpacity="0.28" />
          <stop offset="100%" stopColor={accent} stopOpacity="0" />
        </linearGradient>
      </defs>
      {[0.25, 0.5, 0.75].map((g) => (
        <line key={g} x1={pad.l} x2={w - pad.r} y1={pad.t + g * (h - pad.t - pad.b)} y2={pad.t + g * (h - pad.t - pad.b)} stroke={GM.border} strokeWidth="1" strokeDasharray="2 4" />
      ))}
      {fill && <path d={area} fill={`url(#${gid})`} />}
      <path d={line} fill="none" stroke={accent} strokeWidth="2" strokeLinejoin="round" strokeLinecap="round" />
      {showDots && pts.map((p, i) => i === pts.length - 1 && (
        <circle key={i} cx={p[0]} cy={p[1]} r="3.5" fill={accent} stroke={GM.bg} strokeWidth="2" />
      ))}
    </svg>
  );
}

function Sparkline({ data, accent, width = 120, height = 34 }) {
  const min = Math.min(...data), max = Math.max(...data);
  const range = max - min || 1;
  const ix = (i) => (i / (data.length - 1)) * width;
  const iy = (v) => 4 + (1 - (v - min) / range) * (height - 8);
  const line = data.map((v, i) => `${i ? "L" : "M"}${ix(i).toFixed(1)} ${iy(v).toFixed(1)}`).join(" ");
  return (
    <svg viewBox={`0 0 ${width} ${height}`} width="100%" height={height} preserveAspectRatio="none" style={{ display: "block" }}>
      <path d={line} fill="none" stroke={accent} strokeWidth="1.6" strokeLinejoin="round" strokeLinecap="round" opacity="0.85" />
    </svg>
  );
}

// circular score gauge (270° arc, gap at bottom)
function Gauge({ value, accent, size = 168, stroke = 12 }) {
  const r = (size - stroke) / 2 - 2;
  const cx = size / 2, cy = size / 2;
  const START = 135, SWEEP = 270;
  const polar = (deg) => {
    const a = ((deg - 90) * Math.PI) / 180;
    return [cx + r * Math.cos(a), cy + r * Math.sin(a)];
  };
  const arc = (fromDeg, toDeg) => {
    const s = polar(toDeg), e = polar(fromDeg);
    const large = toDeg - fromDeg <= 180 ? 0 : 1;
    return `M${s[0].toFixed(1)} ${s[1].toFixed(1)} A${r} ${r} 0 ${large} 0 ${e[0].toFixed(1)} ${e[1].toFixed(1)}`;
  };
  const progEnd = START + SWEEP * (value / 100);
  return (
    <div style={{ position: "relative", width: size, height: size }}>
      <svg width={size} height={size}>
        <path d={arc(START, START + SWEEP)} fill="none" stroke={GM.surf} strokeWidth={stroke} strokeLinecap="round" />
        <path d={arc(START, progEnd)} fill="none" stroke={accent} strokeWidth={stroke} strokeLinecap="round" style={{ filter: `drop-shadow(0 0 6px ${accent}66)` }} />
      </svg>
      <div style={{ position: "absolute", inset: 0, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 2 }}>
        <div style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: size * 0.3, fontWeight: 700, color: GM.text, lineHeight: 1 }}>{value}</div>
        <div style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: 9.5, letterSpacing: "0.12em", color: GM.deep }}>/ 100</div>
      </div>
    </div>
  );
}

// radar / spider chart
function Radar({ axes, you, rankAvg, accent, size = 230 }) {
  const cx = size / 2, cy = size / 2;
  const R = size / 2 - 26;
  const n = axes.length;
  const pt = (i, frac) => {
    const ang = (Math.PI * 2 * i) / n - Math.PI / 2;
    return [cx + Math.cos(ang) * R * frac, cy + Math.sin(ang) * R * frac];
  };
  const poly = (vals) => vals.map((v, i) => pt(i, v / 100).join(",")).join(" ");
  return (
    <svg width="100%" height={size} viewBox={`0 0 ${size} ${size}`} style={{ display: "block" }}>
      {[0.25, 0.5, 0.75, 1].map((g) => (
        <polygon key={g} points={axes.map((_, i) => pt(i, g).join(",")).join(" ")} fill="none" stroke={GM.border} strokeWidth="1" />
      ))}
      {axes.map((_, i) => {
        const p = pt(i, 1);
        return <line key={i} x1={cx} y1={cy} x2={p[0]} y2={p[1]} stroke={GM.border} strokeWidth="1" />;
      })}
      <polygon points={poly(rankAvg)} fill="rgba(138,148,166,0.10)" stroke={GM.muted} strokeWidth="1.2" strokeDasharray="3 3" />
      <polygon points={poly(you)} fill={`${accent}22`} stroke={accent} strokeWidth="2" />
      {you.map((v, i) => {
        const p = pt(i, v / 100);
        return <circle key={i} cx={p[0]} cy={p[1]} r="2.6" fill={accent} />;
      })}
      {axes.map((label, i) => {
        const p = pt(i, 1.16);
        return (
          <text key={i} x={p[0]} y={p[1]} fill={GM.muted} fontSize="9.5" fontFamily="'JetBrains Mono', monospace" textAnchor="middle" dominantBaseline="middle" letterSpacing="0.04em">
            {label.toUpperCase()}
          </text>
        );
      })}
    </svg>
  );
}

// horizontal meter bar
function Meter({ value, accent, height = 6, track = GM.surf, glow }) {
  return (
    <div style={{ width: "100%", height, background: track, borderRadius: 999, overflow: "hidden" }}>
      <div style={{ width: `${value}%`, height: "100%", background: accent, borderRadius: 999, boxShadow: glow ? `0 0 8px ${accent}88` : "none" }} />
    </div>
  );
}

Object.assign(window, { GM, Mono, Kicker, Card, SectionTitle, Badge, Delta, Avatar, AreaChart, Sparkline, Gauge, Radar, Meter });
