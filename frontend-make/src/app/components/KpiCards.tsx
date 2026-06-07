import { useState, useEffect } from "react";
import {
  TrendingUp, TrendingDown, Sword, Coins, Zap, Eye,
  Shield, Star, Target, Clock, Flame, Activity, Loader2,
} from "lucide-react";
import { usePlayer } from "../../lib/store";
import { dota } from "../../lib/api";

const periods = [
  { label: "7д", value: "7d", days: 7, limit: 50 },
  { label: "30д", value: "30d", days: 30, limit: 80 },
  { label: "3мес", value: "3m", days: 90, limit: 150 },
  { label: "Сезон", value: "season", days: 0, limit: 150 },
  { label: "Всё", value: "all", days: 0, limit: 200 },
];

// icon + color per metric key returned by the backend metrics service.
const META: Record<string, { icon: any; color: string }> = {
  winrate: { icon: Target, color: "#00D084" },
  kda: { icon: Sword, color: "#3B82F6" },
  gpm: { icon: Coins, color: "#D4AF37" },
  xpm: { icon: Zap, color: "#A78BFA" },
  cs_min: { icon: Star, color: "#F59E0B" },
  hero_dmg_min: { icon: Flame, color: "#EF4444" },
  tower_dmg: { icon: Shield, color: "#06B6D4" },
  heal_min: { icon: Activity, color: "#10B981" },
  deaths: { icon: Clock, color: "#FF4560" },
  assists: { icon: Eye, color: "#8B5CF6" },
  wards: { icon: Eye, color: "#8B5CF6" },
  duration: { icon: Clock, color: "#64748B" },
  denies: { icon: Star, color: "#F97316" },
  kills: { icon: Sword, color: "#EC4899" },
  stacks: { icon: Clock, color: "#F97316" },
};

// Which 12 metrics to show, in order.
const SHOW = ["winrate", "kda", "gpm", "xpm", "cs_min", "hero_dmg_min", "tower_dmg", "heal_min", "deaths", "assists", "wards", "duration"];

// Demo cards shown before a player is loaded.
const DEMO = [
  { key: "winrate", label: "Винрейт", value: "—", sub: "нет данных", icon: Target, color: "#00D084" },
  { key: "kda", label: "KDA", value: "—", sub: "Ср. за игру", icon: Sword, color: "#3B82F6" },
  { key: "gpm", label: "GPM", value: "—", sub: "Золото/мин", icon: Coins, color: "#D4AF37" },
  { key: "xpm", label: "XPM", value: "—", sub: "Опыт/мин", icon: Zap, color: "#A78BFA" },
  { key: "cs_min", label: "CS/мин", value: "—", sub: "Крипы/мин", icon: Star, color: "#F59E0B" },
  { key: "hero_dmg_min", label: "Урон/мин", value: "—", sub: "По героям", icon: Flame, color: "#EF4444" },
];

function fmt(key: string, value: number): string {
  if (key === "winrate") return Math.round(value) + "%";
  if (key === "duration") return value.toFixed(1) + " мин";
  if (value >= 1000) return Math.round(value).toLocaleString("ru-RU");
  return String(value);
}

function subLabel(m: any): string {
  if (m.percentile != null) {
    const top = Math.min(99, Math.max(1, Math.round(100 - m.percentile)));
    return "топ " + top + "% брекета";
  }
  return m.group || "";
}

export function KpiCards() {
  const [period, setPeriod] = useState("30d");
  const { accountId } = usePlayer();
  const [report, setReport] = useState<any>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!accountId) { setReport(null); return; }
    const p = periods.find((x) => x.value === period)!;
    let cancelled = false;
    setLoading(true);
    dota.metrics(accountId, { days: p.days || undefined, limit: p.limit })
      .then((r: any) => { if (!cancelled) setReport(r); })
      .catch(() => { if (!cancelled) setReport(null); })
      .finally(() => { if (!cancelled) setLoading(false); });
    return () => { cancelled = true; };
  }, [accountId, period]);

  let cards: any[];
  if (report?.metrics?.length) {
    const byKey: Record<string, any> = {};
    report.metrics.forEach((m: any) => (byKey[m.key] = m));
    cards = SHOW.filter((k) => byKey[k]).map((k) => {
      const m = byKey[k];
      const meta = META[k] || { icon: Activity, color: "#00D084" };
      return { key: k, label: m.label, value: fmt(k, m.value), sub: subLabel(m), icon: meta.icon, color: meta.color, delta: "", positive: true };
    });
  } else {
    cards = DEMO;
  }

  return (
    <div className="flex flex-col gap-3">
      <div className="flex items-center gap-2">
        <span style={{ fontFamily: "Manrope, sans-serif", fontSize: 11, color: "#8A94A6" }}>Период:</span>
        <div className="flex items-center gap-1 p-1 rounded-lg" style={{ background: "#0B0E13", border: "1px solid #1B2430" }}>
          {periods.map(({ label, value }) => (
            <button key={value} onClick={() => setPeriod(value)}
              style={{
                fontFamily: "Manrope, sans-serif", fontWeight: period === value ? 700 : 500, fontSize: 11,
                padding: "4px 12px", borderRadius: 6, border: "none", cursor: "pointer", transition: "all 0.15s",
                background: period === value ? "#00D084" : "transparent",
                color: period === value ? "#050608" : "#8A94A6",
              }}>
              {label}
            </button>
          ))}
        </div>
        {loading ? <Loader2 size={13} className="animate-spin" color="#00D084" /> : null}
        {report ? <span style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 10.5, color: "#8A94A6" }}>· {report.games} игр</span> : null}
      </div>

      <div className="grid gap-3 grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-6">
        {cards.map(({ key, label, value, delta, positive, icon: Icon, color, sub }) => (
          <div key={key} className="rounded-2xl px-4 py-4 flex flex-col gap-2 transition-colors"
            style={{ background: "#0B0E13", border: "1px solid #161C26" }}>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-1.5">
                <span className="w-6 h-6 rounded-lg flex items-center justify-center" style={{ background: color + "1a" }}>
                  <Icon size={12} color={color} />
                </span>
                <span style={{ fontFamily: "Manrope, sans-serif", fontSize: 11, color: "#8A94A6" }}>{label}</span>
              </div>
              {delta ? (
                <div className="flex items-center gap-0.5" style={{ color: positive ? "#00D084" : "#FF4560" }}>
                  {positive ? <TrendingUp size={9} /> : <TrendingDown size={9} />}
                  <span style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 9 }}>{delta}</span>
                </div>
              ) : null}
            </div>
            <div style={{ fontFamily: "JetBrains Mono, monospace", fontWeight: 700, fontSize: 24, color: "#F4F6FA", letterSpacing: "-0.5px", lineHeight: 1 }}>{value}</div>
            <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 10.5, color: "#6B7480" }}>{sub}</div>
          </div>
        ))}
      </div>
    </div>
  );
}
