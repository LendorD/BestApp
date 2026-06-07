import { useState, useEffect } from "react";
import { Shield, Medal, ExternalLink } from "lucide-react";
import { usePlayer } from "../../lib/store";
import { dota } from "../../lib/api";

const MEDALS = ["", "Herald", "Guardian", "Crusader", "Archon", "Legend", "Ancient", "Divine", "Immortal"];
function rankFromTier(tier?: number): string {
  if (!tier || tier <= 0) return "";
  const medal = Math.floor(tier / 10);
  const stars = tier % 10;
  const name = MEDALS[medal] || "";
  if (!name) return "";
  return medal >= 8 ? name : name + (stars ? " " + stars : "");
}
function rankColor(label: string) {
  const l = (label || "").toLowerCase();
  if (l.includes("immortal")) return "#67E8F9";
  if (l.includes("divine")) return "#A78BFA";
  if (l.includes("ancient")) return "#60A5FA";
  if (l.includes("legend")) return "#34D399";
  if (l.includes("archon")) return "#FBBF24";
  if (l.includes("crusader")) return "#9CA3AF";
  if (l.includes("guardian")) return "#86EFAC";
  if (l.includes("herald")) return "#CA8A4B";
  return "#D4AF37";
}

function Avatar({ url, name }: { url: string; name: string }) {
  const [broken, setBroken] = useState(false);
  if (url && !broken) {
    return <img src={url} alt={name} onError={() => setBroken(true)} style={{ width: "100%", height: "100%", objectFit: "cover" }} />;
  }
  const initials = (name || "?").split(" ").map((w) => w[0]).join("").slice(0, 2).toUpperCase();
  return (
    <div style={{ width: "100%", height: "100%", display: "flex", alignItems: "center", justifyContent: "center", background: "linear-gradient(135deg,#3B82F6,#8B5CF6)", color: "#fff", fontWeight: 800, fontSize: 26, fontFamily: "Manrope, sans-serif" }}>
      {initials}
    </div>
  );
}

export function ProfileHeader() {
  const { accountId } = usePlayer();
  const [prof, setProf] = useState<any>(null);
  const [report, setReport] = useState<any>(null);

  // Source profile + metrics directly (independent of the dashboard mapping).
  useEffect(() => {
    if (!accountId) { setProf(null); setReport(null); return; }
    let cancelled = false;
    dota.profile(accountId).then((r: any) => { if (!cancelled) setProf(r); }).catch(() => {});
    dota.metrics(accountId, { limit: 50 }).then((r: any) => { if (!cancelled) setReport(r); }).catch(() => {});
    return () => { cancelled = true; };
  }, [accountId]);

  const live = !!accountId;
  const name = prof?.persona_name || prof?.personaname || (accountId ? "Player " + accountId : "Найди игрока");
  const avatar = prof?.avatar_full || prof?.avatarfull || prof?.avatar || "";
  const rankLabel = prof?.rank_label || rankFromTier(prof?.rank_tier) || (live ? "Без ранга" : "Immortal");
  const rc = rankColor(rankLabel);

  const metric = (k: string) => report?.metrics?.find((m: any) => m.key === k)?.value;
  const gmScore = report?.scores?.overall;
  const winrate = report?.winrate_pct;
  const kda = metric("kda");
  const games = report?.games;

  const tiles = [
    { label: "GM Score", value: gmScore != null ? String(gmScore) : (live ? "…" : "74") },
    { label: "Winrate", value: winrate != null ? Math.round(winrate) + "%" : (live ? "…" : "63%") },
    { label: "KDA", value: kda != null ? String(kda) : (live ? "…" : "4.2") },
    { label: "Матчей", value: games != null ? String(games) : (live ? "…" : "—") },
  ];

  return (
    <div className="rounded-2xl p-6 flex items-center gap-6 relative overflow-hidden flex-wrap"
      style={{ background: "#0B0E13", border: "1px solid #161C26" }}>
      <div className="absolute inset-0 pointer-events-none"
        style={{ background: `radial-gradient(ellipse 420px 220px at 85% 50%, ${rc}14 0%, transparent 70%)` }} />

      <div className="relative shrink-0">
        <div className="w-20 h-20 rounded-2xl overflow-hidden" style={{ border: `2px solid ${rc}55` }}>
          <Avatar url={avatar} name={name} />
        </div>
        <div className="absolute -bottom-1.5 -right-1.5 w-7 h-7 rounded-full flex items-center justify-center"
          style={{ background: "#0B0E13", border: `2px solid ${rc}` }}>
          <Medal size={14} color={rc} strokeWidth={2} />
        </div>
      </div>

      <div className="flex-1 min-w-0 relative z-10">
        <div className="flex items-center gap-2 mb-1">
          <span style={{ fontFamily: "Manrope, sans-serif", fontWeight: 800, fontSize: 22, color: "#F4F6FA", letterSpacing: "-0.4px", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", maxWidth: 320 }}>{name}</span>
          <span className="px-2 py-0.5 rounded-full" style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 10, fontWeight: 700, letterSpacing: "0.06em", color: live ? "#00D084" : "#8A94A6", background: live ? "rgba(0,208,132,0.12)" : "rgba(138,148,166,0.1)", border: `1px solid ${live ? "rgba(0,208,132,0.3)" : "#1B2430"}` }}>{live ? "LIVE" : "DEMO"}</span>
          {accountId ? (
            <a href={`https://www.opendota.com/players/${accountId}`} target="_blank" rel="noreferrer" style={{ color: "#8A94A6", display: "inline-flex" }} title="Открыть на OpenDota"><ExternalLink size={14} /></a>
          ) : null}
        </div>
        <div className="flex items-center gap-2 mb-4">
          <Shield size={12} color="#8A94A6" />
          <span style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 11, color: "#8A94A6" }}>ID {accountId || "—"}</span>
          <span style={{ color: "#1B2430" }}>·</span>
          <span style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 11, color: "#8A94A6" }}>{games != null ? games + " матчей в анализе" : "—"}</span>
        </div>

        <div className="flex items-center gap-6 flex-wrap">
          {tiles.map(({ label, value }) => (
            <div key={label}>
              <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 11, color: "#8A94A6", marginBottom: 2 }}>{label}</div>
              <div style={{ fontFamily: "JetBrains Mono, monospace", fontWeight: 700, fontSize: 17, color: "#F4F6FA", letterSpacing: "0.02em" }}>{value}</div>
            </div>
          ))}
        </div>
      </div>

      <div className="shrink-0 flex flex-col items-center gap-2 px-5 py-4 rounded-2xl relative z-10"
        style={{ background: "#10141B", border: "1px solid #1B2430" }}>
        <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 10, color: "#8A94A6", letterSpacing: "0.08em" }}>РАНГ</div>
        <div className="w-14 h-14 rounded-full flex items-center justify-center"
          style={{ background: `linear-gradient(135deg, ${rc}33, ${rc}0d)`, border: `1px solid ${rc}55` }}>
          <Medal size={26} color={rc} strokeWidth={1.5} />
        </div>
        <div style={{ fontFamily: "Manrope, sans-serif", fontWeight: 800, fontSize: 13, color: rc, textAlign: "center" }}>{rankLabel}</div>
        <div style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 10, color: "#8A94A6" }}>OpenDota</div>
      </div>
    </div>
  );
}
