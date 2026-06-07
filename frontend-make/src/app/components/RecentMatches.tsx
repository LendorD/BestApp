import { useState, useEffect } from "react";
import { Clock, TrendingUp, TrendingDown, Loader2 } from "lucide-react";
import { usePlayer } from "../../lib/store";
import { dota } from "../../lib/api";
import { heroPortrait, heroName } from "../../lib/heroes";

const PALETTE = ["#4FC3F7", "#A78BFA", "#EF4444", "#38BDF8", "#86EFAC", "#F97316", "#D4AF37", "#10B981"];

const DEMO = [
  { heroId: 1, hero: "Anti-Mage", result: "W", kills: 12, deaths: 2, assists: 7, gpm: 712, duration: "38:14", kda: 9.5 },
  { heroId: 74, hero: "Invoker", result: "W", kills: 8, deaths: 3, assists: 14, gpm: 621, duration: "44:51", kda: 7.3 },
  { heroId: 14, hero: "Pudge", result: "L", kills: 5, deaths: 7, assists: 11, gpm: 340, duration: "31:20", kda: 2.3 },
  { heroId: 10, hero: "Morphling", result: "W", kills: 16, deaths: 1, assists: 5, gpm: 748, duration: "27:08", kda: 21.0 },
  { heroId: 21, hero: "Windranger", result: "L", kills: 6, deaths: 5, assists: 9, gpm: 488, duration: "41:33", kda: 3.0 },
  { heroId: 106, hero: "Ember Spirit", result: "W", kills: 11, deaths: 2, assists: 13, gpm: 598, duration: "35:47", kda: 12.0 },
];

function dur(s: number) {
  const m = Math.floor((s || 0) / 60);
  return m + ":" + String((s || 0) % 60).padStart(2, "0");
}

function HeroAvatar({ heroId, name, color }: { heroId?: number; name: string; color: string }) {
  const [broken, setBroken] = useState(false);
  const img = heroId ? heroPortrait(heroId) : "";
  if (img && !broken) {
    return (
      <div className="w-8 h-6 rounded-md overflow-hidden shrink-0" style={{ border: `1px solid ${color}44` }}>
        <img src={img} alt={name} loading="lazy" onError={() => setBroken(true)}
          style={{ width: "100%", height: "100%", objectFit: "cover", display: "block" }} />
      </div>
    );
  }
  const initials = name.split(" ").map((w) => w[0]).join("").slice(0, 2);
  return (
    <div className="w-7 h-7 rounded-lg flex items-center justify-center shrink-0"
      style={{ background: `${color}22`, border: `1px solid ${color}44`, fontFamily: "Manrope, sans-serif", fontWeight: 700, fontSize: 10, color }}>
      {initials}
    </div>
  );
}

export function RecentMatches() {
  const { accountId } = usePlayer();
  const [rows, setRows] = useState<any[]>(DEMO);
  const [loading, setLoading] = useState(false);
  const [live, setLive] = useState(false);

  useEffect(() => {
    if (!accountId) { setRows(DEMO); setLive(false); return; }
    let cancelled = false;
    setLoading(true);
    dota.rawMatches(accountId, 15)
      .then((arr: any) => {
        if (cancelled) return;
        const list = Array.isArray(arr) ? arr : [];
        const mapped = list.map((m: any, i: number) => {
          const isRadiant = m.player_slot < 128;
          const won = (isRadiant && m.radiant_win) || (!isRadiant && !m.radiant_win);
          const k = m.kills || 0, d = m.deaths || 0, a = m.assists || 0;
          return {
            heroId: m.hero_id, hero: heroName(m.hero_id), color: PALETTE[i % PALETTE.length],
            result: won ? "W" : "L", kills: k, deaths: d, assists: a,
            gpm: m.gold_per_min || 0, duration: dur(m.duration), kda: (k + a) / Math.max(d, 1),
          };
        });
        setRows(mapped.length ? mapped : DEMO);
        setLive(mapped.length > 0);
      })
      .catch(() => { if (!cancelled) { setRows(DEMO); setLive(false); } })
      .finally(() => { if (!cancelled) setLoading(false); });
    return () => { cancelled = true; };
  }, [accountId]);

  return (
    <div className="rounded-2xl overflow-hidden" style={{ background: "#0B0E13", border: "1px solid #161C26" }}>
      <div className="px-5 py-4 flex items-center justify-between border-b" style={{ borderColor: "#1B2430" }}>
        <div className="flex items-center gap-2">
          <div style={{ fontFamily: "Manrope, sans-serif", fontWeight: 700, fontSize: 13, color: "#F4F6FA" }}>Recent Matches</div>
          {loading ? <Loader2 size={13} className="animate-spin" color="#00D084" /> : null}
        </div>
        <div style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 10, color: "#8A94A6" }}>{live ? "LIVE · " : "DEMO · "}{rows.length} games</div>
      </div>
      <div className="overflow-x-auto">
        <table style={{ width: "100%", borderCollapse: "collapse", minWidth: 560 }}>
          <thead>
            <tr style={{ borderBottom: "1px solid #1B2430" }}>
              {["Hero", "Result", "K/D/A", "GPM", "Duration", "KDA"].map((h) => (
                <th key={h} style={{ fontFamily: "Manrope, sans-serif", fontSize: 10, fontWeight: 600, color: "#8A94A6", padding: "8px 12px", textAlign: "left", letterSpacing: "0.05em" }}>{h}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {rows.map((m: any, i: number) => (
              <tr key={i} style={{ borderBottom: "1px solid #1B2430" }} className="hover:bg-[#111620]">
                <td style={{ padding: "10px 12px" }}>
                  <div className="flex items-center gap-2">
                    <HeroAvatar heroId={m.heroId} name={m.hero} color={m.color} />
                    <span style={{ fontFamily: "Manrope, sans-serif", fontSize: 12, fontWeight: 600, color: "#F4F6FA" }}>{m.hero}</span>
                  </div>
                </td>
                <td style={{ padding: "10px 12px" }}>
                  <span className="px-2 py-0.5 rounded text-xs"
                    style={{ fontFamily: "JetBrains Mono, monospace", fontWeight: 700, fontSize: 11, background: m.result === "W" ? "rgba(0,208,132,0.12)" : "rgba(255,69,96,0.12)", color: m.result === "W" ? "#00D084" : "#FF4560" }}>
                    {m.result === "W" ? "WIN" : "LOSS"}
                  </span>
                </td>
                <td style={{ padding: "10px 12px" }}>
                  <span style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 12, color: "#F4F6FA" }}>
                    {m.kills}<span style={{ color: "#1B2430" }}>/</span><span style={{ color: "#FF4560" }}>{m.deaths}</span><span style={{ color: "#1B2430" }}>/</span>{m.assists}
                  </span>
                </td>
                <td style={{ padding: "10px 12px" }}>
                  <span style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 12, color: "#D4AF37" }}>{m.gpm}</span>
                </td>
                <td style={{ padding: "10px 12px" }}>
                  <div className="flex items-center gap-1"><Clock size={11} color="#8A94A6" /><span style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 11, color: "#8A94A6" }}>{m.duration}</span></div>
                </td>
                <td style={{ padding: "10px 12px" }}>
                  <div className="flex items-center gap-1">
                    {m.result === "W" ? <TrendingUp size={11} color="#00D084" /> : <TrendingDown size={11} color="#FF4560" />}
                    <span style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 12, fontWeight: 600, color: m.kda >= 5 ? "#00D084" : m.kda >= 3 ? "#F4F6FA" : "#FF4560" }}>{m.kda.toFixed(1)}</span>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
