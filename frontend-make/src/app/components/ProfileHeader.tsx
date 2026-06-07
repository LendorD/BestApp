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

// Rank medal accent by Dota tier (first digit of rank_tier / label keyword).
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
  const { data, live, accountId: accId } = usePlayer();
  const p = data?.player;
  const [extra, setExtra] = useState<{ avatar?: string; rank?: string }>({});

  // Fetch the player profile for avatar + rank medal (the dashboard payload
  // doesn't always include them).
  useEffect(() => {
    if (!accId) { setExtra({}); return; }
    let cancelled = false;
    dota.profile(accId)
      .then((r: any) => {
        if (cancelled) return;
        setExtra({
          avatar: r?.avatar_full || r?.avatarfull || r?.avatar || "",
          rank: r?.rank_label || rankFromTier(r?.rank_tier),
        });
      })
      .catch(() => {});
    return () => { cancelled = true; };
  }, [accId]);

  const name = p?.name || "Найди игрока";
  const accountId = p?.accountId || accId || "—";
  const avatar = p?.avatar || extra.avatar || "";
  const rankLabel = (p?.rank && p.rank !== "—" ? p.rank : extra.rank) || (data ? "Без ранга" : "Immortal");
  const matches = p?.matches ?? 0;
  const kpi = (l: string) => data?.kpis?.find((k) => k.label === l)?.value;
  const rc = rankColor(rankLabel);

  const tiles = [
    { label: "GM Score", value: data ? String(data.score?.value ?? "—") : "74" },
    { label: "Winrate", value: data ? (kpi("Винрейт") || "—") : "63%" },
    { label: "KDA", value: data ? (kpi("KDA") || "—") : "4.2" },
    { label: "Матчей", value: data ? String(matches) : "—" },
  ];

  return (
    <div className="rounded-2xl p-6 flex items-center gap-6 relative overflow-hidden flex-wrap"
      style={{ background: "#0B0E13", border: "1px solid #161C26" }}>
      <div className="absolute inset-0 pointer-events-none"
        style={{ background: `radial-gradient(ellipse 420px 220px at 85% 50%, ${rc}14 0%, transparent 70%)` }} />

      {/* Avatar + rank medal */}
      <div className="relative shrink-0">
        <div className="w-20 h-20 rounded-2xl overflow-hidden" style={{ border: `2px solid ${rc}55` }}>
          <Avatar url={avatar} name={name} />
        </div>
        <div className="absolute -bottom-1.5 -right-1.5 w-7 h-7 rounded-full flex items-center justify-center"
          style={{ background: "#0B0E13", border: `2px solid ${rc}` }}>
          <Medal size={14} color={rc} strokeWidth={2} />
        </div>
      </div>

      {/* Identity */}
      <div className="flex-1 min-w-0 relative z-10">
        <div className="flex items-center gap-2 mb-1">
          <span style={{ fontFamily: "Manrope, sans-serif", fontWeight: 800, fontSize: 22, color: "#F4F6FA", letterSpacing: "-0.4px", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", maxWidth: 320 }}>{name}</span>
          <span className="px-2 py-0.5 rounded-full" style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 10, fontWeight: 700, letterSpacing: "0.06em", color: live ? "#00D084" : "#8A94A6", background: live ? "rgba(0,208,132,0.12)" : "rgba(138,148,166,0.1)", border: `1px solid ${live ? "rgba(0,208,132,0.3)" : "#1B2430"}` }}>{live ? "LIVE" : "DEMO"}</span>
          {accountId !== "—" ? (
            <a href={`https://www.opendota.com/players/${accountId}`} target="_blank" rel="noreferrer" style={{ color: "#8A94A6", display: "inline-flex" }} title="Открыть на OpenDota"><ExternalLink size={14} /></a>
          ) : null}
        </div>
        <div className="flex items-center gap-2 mb-4">
          <Shield size={12} color="#8A94A6" />
          <span style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 11, color: "#8A94A6" }}>ID {accountId}</span>
          <span style={{ color: "#1B2430" }}>·</span>
          <span style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 11, color: "#8A94A6" }}>{matches} матчей в анализе</span>
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

      {/* Rank card */}
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
