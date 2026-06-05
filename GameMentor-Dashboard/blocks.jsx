/* GameMentor — App Shell + Dashboard content blocks. Exports to window. */

/* ---------- minimal stroke icon set ---------- */
function Icon({ name, size = 18, color = "currentColor", sw = 1.6 }) {
  const P = {
    grid: "M3 3h7v7H3zM14 3h7v7h-7zM3 14h7v7H3zM14 14h7v7h-7z",
    user: "M12 12a4 4 0 100-8 4 4 0 000 8zM5 20c0-3.3 3.1-5 7-5s7 1.7 7 5",
    spark: "M12 3v4M12 17v4M3 12h4M17 12h4M6 6l2.5 2.5M15.5 15.5L18 18M18 6l-2.5 2.5M8.5 15.5L6 18",
    search: "M11 11m-7 0a7 7 0 1014 0 7 7 0 10-14 0M20 20l-4-4",
    cube: "M12 3l8 4.5v9L12 21l-8-4.5v-9zM12 3v18M4 7.5l8 4.5 8-4.5",
    target: "M12 12m-9 0a9 9 0 1018 0 9 9 0 10-18 0M12 12m-4.5 0a4.5 4.5 0 109 0 4.5 4.5 0 10-9 0M12 12h.01",
    graph: "M3 3v18h18M7 14l3-4 3 2 4-6",
    crown: "M4 18h16M4 18l-1.5-9 5 3.5L12 5l4.5 7.5 5-3.5L20 18",
    pin: "M12 21s7-6 7-11a7 7 0 10-14 0c0 5 7 11 7 11zM12 10m-2 0a2 2 0 104 0 2 2 0 10-4 0",
    drop: "M12 3s6 7 6 11a6 6 0 11-12 0c0-4 6-11 6-11z",
    squares: "M3 3h8v8H3zM13 3h8v8h-8zM3 13h8v8H3zM13 13h8v8h-8z",
    bolt: "M13 2L4 14h7l-1 8 9-12h-7l1-8z",
    bell: "M18 8a6 6 0 10-12 0c0 7-3 9-3 9h18s-3-2-3-9M13.7 21a2 2 0 01-3.4 0",
    gear: "M12 15a3 3 0 100-6 3 3 0 000 6zM19.4 15a1.6 1.6 0 00.3 1.8l.1.1a2 2 0 11-2.8 2.8l-.1-.1a1.6 1.6 0 00-2.7 1.1V21a2 2 0 01-4 0v-.1A1.6 1.6 0 005 19.4l-.1.1a2 2 0 11-2.8-2.8l.1-.1A1.6 1.6 0 003.3 14H3a2 2 0 010-4h.1A1.6 1.6 0 004.6 8L4.5 8a2 2 0 112.8-2.8l.1.1A1.6 1.6 0 0010 4.6V4a2 2 0 014 0v.1A1.6 1.6 0 0016.7 6l.1-.1a2 2 0 112.8 2.8l-.1.1a1.6 1.6 0 00-.3 1.8 1.6 1.6 0 001.5 1H21a2 2 0 010 4h-.1a1.6 1.6 0 00-1.5 1z",
  };
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round">
      <path d={P[name] || P.grid} />
    </svg>
  );
}

const NAV = {
  dota: [
    { label: "Dashboard", icon: "grid", active: true },
    { label: "Мой профиль", icon: "user" },
    { label: "AI Coach", icon: "spark", pro: true },
    { label: "Match Review", icon: "search" },
    { label: "Heroes", icon: "cube" },
    { label: "Training", icon: "target" },
    { label: "Meta", icon: "graph" },
    { label: "Subscription", icon: "crown", pro: true },
  ],
  cs2: [
    { label: "Dashboard", icon: "grid", active: true },
    { label: "Maps", icon: "pin" },
    { label: "Grenades", icon: "drop" },
    { label: "Training", icon: "target" },
    { label: "Utility Sets", icon: "squares" },
    { label: "AI Coach", icon: "spark", pro: true },
    { label: "Subscription", icon: "crown", pro: true },
  ],
};

/* ---------- Sidebar ---------- */
function Sidebar({ game, accent, onGame }) {
  const nav = NAV[game];
  return (
    <aside style={{ width: 244, flexShrink: 0, background: GM.card, borderRight: `1px solid ${GM.border}`, padding: "20px 14px", display: "flex", flexDirection: "column", gap: 18 }}>
      {/* brand */}
      <div style={{ display: "flex", alignItems: "center", gap: 11, padding: "0 4px" }}>
        <div style={{ width: 38, height: 38, borderRadius: 8, background: GM.bg, border: `1px solid ${accent}`, display: "flex", alignItems: "center", justifyContent: "center", color: accent, fontWeight: 900, fontSize: 19 }}>G</div>
        <div>
          <div style={{ fontWeight: 900, fontSize: 16, letterSpacing: "-0.02em" }}>GameMentor</div>
          <div style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: 9.5, letterSpacing: "0.14em", color: accent }}>{game === "dota" ? "DOTA 2 LAB" : "CS2 LAB"}</div>
        </div>
      </div>

      {/* product switcher */}
      <div style={{ display: "flex", gap: 4, padding: 4, background: GM.bg, border: `1px solid ${GM.border}`, borderRadius: 8 }}>
        {[["dota", "Dota 2", "#00D084"], ["cs2", "CS2", "#FF6B00"]].map(([g, lbl, c]) => (
          <button key={g} onClick={() => onGame && onGame(g)} style={{ flex: 1, border: "none", cursor: "pointer", padding: "8px 0", borderRadius: 6, fontWeight: 800, fontSize: 12.5, fontFamily: "inherit", background: game === g ? c : "transparent", color: game === g ? GM.bg : GM.muted }}>{lbl}</button>
        ))}
      </div>

      <div>
        <Kicker style={{ padding: "0 6px" }}>Menu</Kicker>
        <div style={{ display: "flex", flexDirection: "column", gap: 3, marginTop: 9 }}>
          {nav.map((n) => {
            const isActive = n.active;
            const col = n.pro ? GM.premium : accent;
            return (
              <div key={n.label} style={{ position: "relative", display: "flex", alignItems: "center", gap: 11, padding: "9px 11px", borderRadius: 7, cursor: "pointer", color: isActive ? GM.text : GM.muted, background: isActive ? `${accent}14` : "transparent", border: `1px solid ${isActive ? accent + "3a" : "transparent"}`, fontWeight: isActive ? 800 : 600, fontSize: 13.5 }}>
                {isActive && <div style={{ position: "absolute", left: -14, top: 8, bottom: 8, width: 3, borderRadius: 2, background: accent }} />}
                <Icon name={n.icon} size={17} color={isActive ? accent : GM.deep} />
                <span style={{ flex: 1 }}>{n.label}</span>
                {n.pro && <span style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: 8.5, fontWeight: 700, letterSpacing: "0.1em", color: GM.premium, border: `1px solid ${GM.premium}55`, borderRadius: 4, padding: "1px 4px" }}>PRO</span>}
              </div>
            );
          })}
        </div>
      </div>

      <div style={{ marginTop: "auto", padding: 12, background: GM.bg, border: `1px solid ${GM.border}`, borderRadius: 8 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
          <span style={{ width: 7, height: 7, borderRadius: 999, background: "#00D084", boxShadow: "0 0 6px #00D084" }} />
          <span style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: 11, fontWeight: 600, color: GM.text }}>Live API</span>
        </div>
        <div style={{ fontSize: 10.5, color: GM.deep, marginTop: 5, fontFamily: "'JetBrains Mono', monospace" }}>OpenDota · synced 2m ago</div>
      </div>
    </aside>
  );
}

/* ---------- Top bar ---------- */
function TopBar({ d, accent, game }) {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 16, padding: "14px 26px", borderBottom: `1px solid ${GM.border}`, background: "rgba(8,11,16,0.6)" }}>
      <div style={{ flex: 1 }}>
        <Kicker color={GM.deep}>{game === "dota" ? "DOTA 2 LAB" : "CS2 LAB"} / OVERVIEW</Kicker>
        <div style={{ fontSize: 17, fontWeight: 800, letterSpacing: "-0.01em", marginTop: 2 }}>Player Dashboard</div>
      </div>
      <div style={{ display: "flex", alignItems: "center", background: GM.card, border: `1px solid ${GM.border}`, borderRadius: 8, padding: "8px 12px", gap: 9, width: 240 }}>
        <Icon name="search" size={15} color={GM.deep} />
        <span style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: 12, color: GM.deep }}>Search player ID…</span>
      </div>
      <Badge color={GM.premium}>◆ PREMIUM</Badge>
      <div style={{ display: "flex", gap: 8 }}>
        {["bell", "gear"].map((i) => (
          <div key={i} style={{ width: 38, height: 38, borderRadius: 8, background: GM.card, border: `1px solid ${GM.border}`, display: "flex", alignItems: "center", justifyContent: "center", color: GM.muted }}><Icon name={i} size={17} /></div>
        ))}
        <Avatar letter={d.player.avatar} accent={accent} size={38} />
      </div>
    </div>
  );
}

/* ---------- Period / game tabs strip ---------- */
function PeriodTabs({ accent, period, setPeriod }) {
  return (
    <div style={{ display: "flex", gap: 4, padding: 3, background: GM.card, border: `1px solid ${GM.border}`, borderRadius: 7 }}>
      {["7D", "30D", "90D"].map((p) => (
        <button key={p} onClick={() => setPeriod && setPeriod(p)} style={{ border: "none", cursor: "pointer", fontFamily: "'JetBrains Mono', monospace", fontWeight: 600, fontSize: 11.5, padding: "6px 13px", borderRadius: 5, background: period === p ? accent : "transparent", color: period === p ? GM.bg : GM.muted }}>{p}</button>
      ))}
    </div>
  );
}

/* ======================= CONTENT BLOCKS ======================= */

/* Profile hero header */
function ProfileHeader({ d, accent, period, setPeriod }) {
  const p = d.player;
  return (
    <Card glow accent={accent} pad={0} style={{ borderColor: `${accent}3a` }}>
      <div style={{ display: "flex", alignItems: "stretch", gap: 0, flexWrap: "wrap" }}>
        <div style={{ flex: "1 1 420px", padding: 22, display: "flex", gap: 18, alignItems: "center" }}>
          <Avatar letter={p.avatar} accent={accent} size={76} />
          <div style={{ minWidth: 0 }}>
            <Kicker color={accent}>{p.seasonLabel}</Kicker>
            <div style={{ display: "flex", alignItems: "baseline", gap: 10, marginTop: 4 }}>
              <span style={{ fontSize: 26, fontWeight: 900, letterSpacing: "-0.02em" }}>{p.name}</span>
              <Mono style={{ fontSize: 12, color: GM.deep }}>#{p.accountId}</Mono>
            </div>
            <div style={{ display: "flex", flexWrap: "wrap", gap: 8, marginTop: 10 }}>
              <Badge color={accent}>{p.rankTier}</Badge>
              <span style={{ display: "inline-flex", alignItems: "center", gap: 6, fontSize: 12, color: GM.muted, fontWeight: 600 }}>
                <Mono style={{ color: GM.text, fontWeight: 700 }}>{p.mmr}</Mono> {game(d)} · <Delta value={"+" + p.mmrDelta} up />
              </span>
              <span style={{ fontSize: 12, color: GM.muted, fontWeight: 600 }}>{p.region}</span>
              <span style={{ fontSize: 12, color: GM.muted, fontWeight: 600 }}>{p.rolesLine}</span>
            </div>
          </div>
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 22, padding: "0 24px", borderLeft: `1px solid ${GM.border}` }}>
          <HeaderStat label="Rank percentile" value={d.score.percentile} accent={accent} />
          <HeaderStat label="Form (10g)" value={formStr(d)} accent={accent} />
        </div>
        <div style={{ display: "flex", alignItems: "center", padding: "0 22px 0 0" }}>
          <PeriodTabs accent={accent} period={period} setPeriod={setPeriod} />
        </div>
      </div>
    </Card>
  );
}
function game(d) { return d.accent === "#FF6B00" ? "ELO" : "MMR"; }
function formStr(d) {
  return d.matches.slice(0, 5).map((m) => m.result).join(" ");
}
function HeaderStat({ label, value, accent }) {
  return (
    <div>
      <Kicker>{label}</Kicker>
      <div style={{ fontSize: 18, fontWeight: 800, color: accent, marginTop: 4, fontFamily: "'JetBrains Mono', monospace" }}>{value}</div>
    </div>
  );
}

/* Score panel — Leetify style */
function ScorePanel({ d, accent, big }) {
  const s = d.score;
  return (
    <Card glow accent={accent} pad={20} style={{ height: "100%" }}>
      <SectionTitle title="GameMentor Score" sub={s.caption} right={<Delta value={"+" + s.delta} up />} />
      <div style={{ display: "flex", gap: 22, alignItems: "center", flexWrap: big ? "nowrap" : "wrap" }}>
        <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 8 }}>
          <Gauge value={s.value} accent={accent} size={big ? 180 : 156} />
          <Badge color={accent}>{s.percentile}</Badge>
        </div>
        <div style={{ flex: 1, minWidth: 220, display: "flex", flexDirection: "column", gap: big ? 13 : 10 }}>
          {s.breakdown.map((b) => (
            <div key={b.label}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline", marginBottom: 5 }}>
                <span style={{ fontSize: 12.5, fontWeight: 700, color: GM.text }}>{b.label}</span>
                <Mono style={{ fontSize: 12, color: b.value >= 75 ? accent : b.value < 62 ? GM.red : GM.muted, fontWeight: 700 }}>{b.value}</Mono>
              </div>
              <Meter value={b.value} accent={b.value < 62 ? GM.red : accent} glow={b.value >= 75} />
            </div>
          ))}
        </div>
      </div>
    </Card>
  );
}

/* KPI cards */
function KpiCard({ k, accent }) {
  return (
    <Card pad={14} style={{ minWidth: 0 }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
        <Kicker>{k.label}</Kicker>
        <Delta value={k.delta} up={k.up} />
      </div>
      <div style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: 25, fontWeight: 700, color: GM.text, margin: "8px 0 4px", letterSpacing: "-0.01em" }}>{k.value}</div>
      <Sparkline data={k.spark} accent={k.up ? accent : GM.red} height={28} />
    </Card>
  );
}
function KpiGrid({ d, accent, cols = 3 }) {
  return (
    <div style={{ display: "grid", gridTemplateColumns: `repeat(${cols}, 1fr)`, gap: 12 }}>
      {d.kpis.map((k) => <KpiCard key={k.label} k={k} accent={accent} />)}
    </div>
  );
}

/* Trend chart */
function TrendCard({ d, accent }) {
  const [mode, setMode] = React.useState("winrate");
  const data = mode === "winrate" ? d.trend.winrate : d.trend.mmr;
  return (
    <Card pad={18} style={{ height: "100%" }}>
      <SectionTitle
        title="Performance Trend"
        sub="Rolling window · last 16 sessions"
        right={
          <div style={{ display: "flex", gap: 4, padding: 3, background: GM.bg, border: `1px solid ${GM.border}`, borderRadius: 7 }}>
            {[["winrate", "Winrate"], ["mmr", game2(d)]].map(([m, lbl]) => (
              <button key={m} onClick={() => setMode(m)} style={{ border: "none", cursor: "pointer", fontFamily: "'JetBrains Mono', monospace", fontWeight: 600, fontSize: 11, padding: "5px 11px", borderRadius: 5, background: mode === m ? accent : "transparent", color: mode === m ? GM.bg : GM.muted }}>{lbl}</button>
            ))}
          </div>
        }
      />
      <div style={{ display: "flex", alignItems: "baseline", gap: 10, marginBottom: 8 }}>
        <span style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: 28, fontWeight: 700 }}>{mode === "winrate" ? data[data.length - 1] + "%" : data[data.length - 1]}</span>
        <Delta value={mode === "winrate" ? "+4%" : "+184"} up />
        <span style={{ fontSize: 12, color: GM.deep }}>vs start of period</span>
      </div>
      <AreaChart data={data} accent={accent} height={156} showDots />
    </Card>
  );
}
function game2(d) { return d.accent === "#FF6B00" ? "Elo" : "MMR"; }

/* Radar */
function RadarCard({ d, accent }) {
  return (
    <Card pad={18} style={{ height: "100%" }}>
      <SectionTitle title="Skill Profile" sub="You vs rank average" />
      <Radar axes={d.radar.axes} you={d.radar.you} rankAvg={d.radar.rankAvg} accent={accent} size={236} />
      <div style={{ display: "flex", justifyContent: "center", gap: 18, marginTop: 6 }}>
        <Legend color={accent} label="You" />
        <Legend color={GM.muted} label="Rank avg" dashed />
      </div>
    </Card>
  );
}
function Legend({ color, label, dashed }) {
  return (
    <span style={{ display: "inline-flex", alignItems: "center", gap: 7, fontSize: 11.5, color: GM.muted, fontWeight: 600 }}>
      <span style={{ width: 16, height: 0, borderTop: `2px ${dashed ? "dashed" : "solid"} ${color}` }} />{label}
    </span>
  );
}

/* AI insights */
function AiInsights({ d, accent, layout = "row" }) {
  const map = { weak: GM.red, strong: accent, focus: GM.premium };
  return (
    <Card pad={18} glow accent={GM.premium} style={{ borderColor: `${GM.premium}33` }}>
      <SectionTitle
        title={<span style={{ display: "inline-flex", alignItems: "center", gap: 8 }}><Icon name="spark" size={17} color={GM.premium} /> AI Coach Insights</span>}
        sub="Generated from your last 100 matches"
        right={<Badge color={GM.premium}>◆ PRO</Badge>}
      />
      <div style={{ display: layout === "row" ? "grid" : "flex", gridTemplateColumns: layout === "row" ? "repeat(3,1fr)" : undefined, flexDirection: layout === "col" ? "column" : undefined, gap: 12 }}>
        {d.insights.map((it) => (
          <div key={it.title} style={{ background: GM.bg, border: `1px solid ${GM.border}`, borderLeft: `3px solid ${map[it.kind]}`, borderRadius: 7, padding: 14 }}>
            <Kicker color={map[it.kind]}>{it.tag}</Kicker>
            <div style={{ fontSize: 14, fontWeight: 800, margin: "8px 0 6px", lineHeight: 1.25 }}>{it.title}</div>
            <div style={{ fontSize: 12.5, color: GM.muted, lineHeight: 1.5 }}>{it.body}</div>
          </div>
        ))}
      </div>
      <button style={{ marginTop: 14, width: "100%", border: `1px solid ${GM.premium}`, background: `${GM.premium}16`, color: GM.premium, fontWeight: 800, fontSize: 13, fontFamily: "inherit", padding: "11px 0", borderRadius: 7, cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 8 }}>
        <Icon name="bolt" size={15} color={GM.premium} /> Generate full AI report
      </button>
    </Card>
  );
}

/* Recent matches */
function MatchesTable({ d, accent, rows = 6, dense }) {
  const isCs = d.accent === "#FF6B00";
  return (
    <Card pad={0} style={{ height: "100%" }}>
      <div style={{ padding: "16px 18px 12px" }}>
        <SectionTitle title="Recent Matches" sub={`Last ${d.matches.length} · ${isCs ? "Premier" : "Ranked"}`} right={<span style={{ fontSize: 12, color: accent, fontWeight: 700, cursor: "pointer" }}>View all →</span>} />
      </div>
      <div style={{ display: "grid", gridTemplateColumns: isCs ? "1.4fr 0.5fr 0.9fr 1fr 0.8fr 0.6fr" : "1.4fr 0.5fr 1fr 0.8fr 0.8fr 0.6fr", padding: "0 18px 8px", gap: 8 }}>
        {(isCs ? ["Map", "", "K/D/A", "Score", "ADR", "Rating"] : ["Hero", "", "K/D/A", "GPM", "Duration", "Impact"]).map((h, i) => (
          <Kicker key={i} style={{ textAlign: i > 1 ? "right" : "left" }}>{h}</Kicker>
        ))}
      </div>
      <div>
        {d.matches.slice(0, rows).map((m, i) => (
          <div key={i} style={{ display: "grid", gridTemplateColumns: isCs ? "1.4fr 0.5fr 0.9fr 1fr 0.8fr 0.6fr" : "1.4fr 0.5fr 1fr 0.8fr 0.8fr 0.6fr", alignItems: "center", gap: 8, padding: "10px 18px", borderTop: `1px solid ${GM.borderSoft}`, position: "relative" }}>
            <div style={{ position: "absolute", left: 0, top: 0, bottom: 0, width: 3, background: m.result === "W" ? accent : GM.red, opacity: 0.7 }} />
            <div style={{ display: "flex", alignItems: "center", gap: 10, minWidth: 0 }}>
              <div style={{ width: 30, height: 30, borderRadius: 6, background: GM.surf, border: `1px solid ${GM.border}`, display: "flex", alignItems: "center", justifyContent: "center", fontFamily: "'JetBrains Mono', monospace", fontSize: 11, fontWeight: 700, color: GM.muted, flexShrink: 0 }}>{m.hi}</div>
              <div style={{ minWidth: 0 }}>
                <div style={{ fontSize: 12.5, fontWeight: 700, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{m.hero}</div>
                <Mono style={{ fontSize: 10, color: GM.deep }}>{m.when} ago</Mono>
              </div>
            </div>
            <span style={{ fontFamily: "'JetBrains Mono', monospace", fontWeight: 700, fontSize: 12, color: m.result === "W" ? accent : GM.red }}>{m.result}</span>
            <Mono style={{ textAlign: "right", fontSize: 12, color: GM.text }}>{m.kda}</Mono>
            <Mono style={{ textAlign: "right", fontSize: 12, color: GM.muted }}>{isCs ? m.score : m.gpm}</Mono>
            <Mono style={{ textAlign: "right", fontSize: 12, color: GM.muted }}>{m.dur}</Mono>
            <Mono style={{ textAlign: "right", fontSize: 12, fontWeight: 700, color: m.impact >= (isCs ? 1.2 : 8) ? accent : GM.muted }}>{m.impact}</Mono>
          </div>
        ))}
      </div>
    </Card>
  );
}

/* Leaderboard / pro compare */
function LeaderboardCard({ d, accent }) {
  return (
    <Card pad={18} style={{ height: "100%" }}>
      <SectionTitle title="Pro Benchmark" sub={d.leaderboard.caption} />
      <div style={{ display: "flex", flexDirection: "column", gap: 7, marginBottom: 16 }}>
        {d.leaderboard.rows.map((r, i) => (
          <div key={r.name} style={{ display: "flex", alignItems: "center", gap: 11, padding: "8px 11px", borderRadius: 7, background: r.you ? `${accent}14` : GM.bg, border: `1px solid ${r.you ? accent + "3a" : GM.border}` }}>
            <Mono style={{ fontSize: 12, color: GM.deep, width: 16 }}>{i + 1}</Mono>
            <div style={{ width: 26, height: 26, borderRadius: 6, background: GM.surf, border: `1px solid ${GM.border}`, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 11, fontWeight: 800, color: r.you ? accent : GM.muted }}>{r.name[0]}</div>
            <span style={{ flex: 1, fontSize: 13, fontWeight: r.you ? 800 : 600, color: r.you ? GM.text : GM.muted }}>{r.name}{r.you && <span style={{ color: accent, marginLeft: 6, fontSize: 10, fontFamily: "'JetBrains Mono', monospace" }}>YOU</span>}</span>
            <Mono style={{ fontSize: 13, fontWeight: 700, color: r.you ? accent : GM.text }}>{r.score}</Mono>
          </div>
        ))}
      </div>
      <div style={{ display: "flex", flexDirection: "column", gap: 11 }}>
        {d.leaderboard.bars.map((b) => (
          <div key={b.label}>
            <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 5 }}>
              <span style={{ fontSize: 11.5, fontWeight: 700, color: GM.muted }}>{b.label}</span>
              <Mono style={{ fontSize: 11, color: GM.deep }}>{b.you} / <span style={{ color: GM.premium }}>{b.pro}</span></Mono>
            </div>
            <div style={{ position: "relative", height: 6, background: GM.surf, borderRadius: 999 }}>
              <div style={{ position: "absolute", left: 0, top: 0, bottom: 0, width: `${b.pro}%`, background: `${GM.premium}40`, borderRadius: 999 }} />
              <div style={{ position: "absolute", left: 0, top: 0, bottom: 0, width: `${b.you}%`, background: accent, borderRadius: 999 }} />
            </div>
          </div>
        ))}
      </div>
    </Card>
  );
}

/* Training goals */
function TrainingGoals({ d, accent, layout = "row" }) {
  return (
    <Card pad={18}>
      <SectionTitle title={<span style={{ display: "inline-flex", alignItems: "center", gap: 8 }}><Icon name="target" size={17} color={accent} /> Training Goals</span>} sub="Weekly improvement plan" right={<Mono style={{ fontSize: 11, color: GM.deep }}>3 ACTIVE</Mono>} />
      <div style={{ display: "grid", gridTemplateColumns: layout === "row" ? "repeat(3,1fr)" : "1fr", gap: 12 }}>
        {d.goals.map((g) => (
          <div key={g.label} style={{ background: GM.bg, border: `1px solid ${GM.border}`, borderRadius: 7, padding: 14 }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", gap: 8, marginBottom: 10 }}>
              <span style={{ fontSize: 12.5, fontWeight: 700, lineHeight: 1.3 }}>{g.label}</span>
              <Mono style={{ fontSize: 14, fontWeight: 700, color: accent }}>{g.pct}%</Mono>
            </div>
            <Meter value={g.pct} accent={accent} glow />
            <Mono style={{ fontSize: 10.5, color: GM.deep, marginTop: 8, display: "block" }}>{g.sub}</Mono>
          </div>
        ))}
      </div>
    </Card>
  );
}

Object.assign(window, {
  Icon, Sidebar, TopBar, PeriodTabs, ProfileHeader, ScorePanel, KpiGrid, KpiCard,
  TrendCard, RadarCard, AiInsights, MatchesTable, LeaderboardCard, TrainingGoals,
});
