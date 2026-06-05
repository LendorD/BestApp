/* GameMentor — Dashboard layout variants + full app frame (exports to window) */

function Stack({ children, gap = 16 }) {
  return <div style={{ display: "flex", flexDirection: "column", gap }}>{children}</div>;
}
function Cols({ children, t, gap = 16, align = "stretch" }) {
  return <div style={{ display: "grid", gridTemplateColumns: t, gap, alignItems: align }}>{children}</div>;
}

/* ---------- Variant A — Command Center ---------- */
function PageA(props) {
  const { d, accent } = props;
  return (
    <Stack>
      <ProfileHeader {...props} />
      <Cols t="5fr 7fr">
        <ScorePanel d={d} accent={accent} />
        <KpiGrid d={d} accent={accent} cols={3} />
      </Cols>
      <Cols t="7fr 5fr">
        <TrendCard d={d} accent={accent} />
        <RadarCard d={d} accent={accent} />
      </Cols>
      <AiInsights d={d} accent={accent} layout="row" />
      <Cols t="7fr 5fr">
        <MatchesTable d={d} accent={accent} rows={6} />
        <LeaderboardCard d={d} accent={accent} />
      </Cols>
      <TrainingGoals d={d} accent={accent} layout="row" />
    </Stack>
  );
}

/* ---------- Variant B — Score-First (Leetify) ---------- */
function PageB(props) {
  const { d, accent } = props;
  return (
    <Stack>
      <ProfileHeader {...props} />
      <Cols t="1.55fr 1fr">
        <ScorePanel d={d} accent={accent} big />
        <RadarCard d={d} accent={accent} />
      </Cols>
      <KpiGrid d={d} accent={accent} cols={6} />
      <TrendCard d={d} accent={accent} />
      <AiInsights d={d} accent={accent} layout="row" />
      <Cols t="1fr 1fr">
        <MatchesTable d={d} accent={accent} rows={6} />
        <LeaderboardCard d={d} accent={accent} />
      </Cols>
      <TrainingGoals d={d} accent={accent} layout="row" />
    </Stack>
  );
}

/* ---------- Variant C — Pro Dense (Stratz / Faceit) ---------- */
function PageC(props) {
  const { d, accent } = props;
  return (
    <Stack gap={14}>
      <ProfileHeader {...props} />
      <Cols t="1fr 1fr 1fr" gap={14} align="start">
        <Stack gap={14}>
          <ScorePanel d={d} accent={accent} />
          <RadarCard d={d} accent={accent} />
        </Stack>
        <Stack gap={14}>
          <TrendCard d={d} accent={accent} />
          <KpiGrid d={d} accent={accent} cols={2} />
        </Stack>
        <Stack gap={14}>
          <AiInsights d={d} accent={accent} layout="col" />
          <TrainingGoals d={d} accent={accent} layout="col" />
        </Stack>
      </Cols>
      <Cols t="2fr 1fr" gap={14} align="start">
        <MatchesTable d={d} accent={accent} rows={7} />
        <LeaderboardCard d={d} accent={accent} />
      </Cols>
    </Stack>
  );
}

const PAGES = { A: PageA, B: PageB, C: PageC };

/* ---------- Full app frame (shell + page) ---------- */
function DashboardApp({ variant, initialGame, accentOverride }) {
  const [gameKey, setGameKey] = React.useState(initialGame || "dota");
  const [period, setPeriod] = React.useState("30D");
  const d = window.GM_DATA[gameKey];
  const accent = accentOverride || d.accent;
  const Page = PAGES[variant];
  return (
    <div style={{ display: "flex", minHeight: 900, background: GM.bg, color: GM.text, fontFamily: "Manrope, sans-serif", position: "relative" }}>
      <div style={{ position: "absolute", inset: 0, backgroundImage: `linear-gradient(${GM.border}55 1px, transparent 1px), linear-gradient(90deg, ${GM.border}55 1px, transparent 1px)`, backgroundSize: "56px 56px", opacity: 0.35, pointerEvents: "none" }} />
      <Sidebar game={gameKey} accent={accent} onGame={setGameKey} />
      <div style={{ flex: 1, minWidth: 0, position: "relative", zIndex: 1 }}>
        <TopBar d={d} accent={accent} game={gameKey} />
        <div style={{ padding: 22 }}>
          <Page d={d} accent={accent} game={gameKey} period={period} setPeriod={setPeriod} />
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { Stack, Cols, PageA, PageB, PageC, DashboardApp });
