import { heroName } from "./heroes";

const clamp = (v: number, lo = 0, hi = 100) => Math.max(lo, Math.min(hi, v));
const fmtK = (n: number) => (n >= 1000 ? (n / 1000).toFixed(1) + "k" : String(Math.round(n || 0)));

export interface PlayerData {
  live: boolean;
  player: { name: string; accountId: string; region: string; rank: string; peakMmr: string; mmr: string; hours: string; avatar: string; matches: number };
  score: { value: number; breakdown: { label: string; value: number }[] };
  kpis: { label: string; value: string; sub: string; delta: string; positive: boolean }[];
  trend: { date: string; winrate: number; kda: number }[];
  radar: { axis: string; value: number }[];
  matches: { heroId: number; hero: string; result: "W" | "L"; kda: string; gpm: number; dur: string; impact: string }[];
  insights: { kind: string; title: string; body: string }[];
}

function dur(s: number) { const m = Math.floor((s || 0) / 60); return m + ":" + String((s || 0) % 60).padStart(2, "0"); }

export function mapDashboard(api: any): PlayerData | null {
  if (!api || !api.summary) return null;
  const p = api.player || {}, s = api.summary || {}, perf = api.performance || {};
  const wr = s.winrate ?? p.winrate ?? 0, kda = s.average_kda ?? 0;

  const fm = api.form_timeline?.matches || [];
  let won = 0;
  const trend = fm.map((m: any, i: number) => {
    if (m.won) won++;
    return { date: "M" + (i + 1), winrate: Math.round((won / (i + 1)) * 100), kda: Math.round((m.kda || 0) * 10) / 10 };
  });

  return {
    live: true,
    player: {
      name: p.persona_name || `Player ${p.account_id || api.steam_id}`,
      accountId: String(api.steam_id || p.account_id || ""),
      region: "OpenDota",
      rank: p.rank_label || "—",
      peakMmr: "—",
      mmr: "—",
      hours: String(s.matches || 0) + " matches",
      avatar: p.avatar_full || p.avatarfull || p.avatar || p.avatarmedium || "",
      matches: s.matches || 0,
    },
    score: {
      value: clamp(Math.round(perf.total ?? 0)),
      breakdown: (perf.breakdown || []).map((b: any) => ({ label: b.label, value: clamp(Math.round(b.score)) })),
    },
    kpis: [
      { label: "Винрейт", value: wr.toFixed(0) + "%", sub: (s.matches || 0) + " игр", delta: "", positive: wr >= 50 },
      { label: "KDA", value: kda.toFixed(2), sub: "Ср. за игру", delta: "", positive: kda >= 3 },
      { label: "GPM", value: String(Math.round(s.average_gpm || 0)), sub: "Золото/мин", delta: "", positive: true },
      { label: "XPM", value: String(Math.round(s.average_xpm || 0)), sub: "Опыт/мин", delta: "", positive: true },
      { label: "CS/мин", value: ((s.average_last_hits || 0) / Math.max(s.average_duration_minutes || 1, 1)).toFixed(1), sub: "Крипы/мин", delta: "", positive: true },
      { label: "Дамаг", value: fmtK(s.average_hero_damage || 0), sub: "По героям", delta: "", positive: true },
      { label: "Башни", value: fmtK(s.average_tower_damage || 0), sub: "По башням", delta: "", positive: true },
      { label: "Хил", value: fmtK(s.average_hero_healing || 0), sub: "Исцелено", delta: "", positive: true },
      { label: "Длит.", value: dur(Math.round((s.average_duration_minutes || 0) * 60)), sub: "Ср. матч", delta: "", positive: true },
    ],
    trend: trend.length ? trend : [],
    radar: (perf.breakdown || []).map((b: any) => ({ axis: b.label, value: clamp(Math.round(b.score)) })),
    matches: (api.matches || []).slice(0, 15).map((m: any) => ({
      heroId: m.hero_id, hero: heroName(m.hero_id), result: m.won ? "W" : "L",
      kda: `${m.kills}/${m.deaths}/${m.assists}`, gpm: m.gold_per_min, dur: dur(m.duration_seconds),
      impact: ((m.kills + m.assists * 0.5) / Math.max(m.deaths, 1)).toFixed(1),
    })),
    insights: (api.weaknesses || []).slice(0, 3).map((w: any) => ({ kind: (w.severity || "focus"), title: w.title, body: w.message })),
  };
}
