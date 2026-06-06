import { Shield, Star, ExternalLink, Trophy, Clock } from "lucide-react";
import { usePlayer } from "../../lib/store";

export function ProfileHeader() {
  const { data } = usePlayer();
  const p = data?.player;
  const name = p?.name || "baumi";
  const accountId = p?.accountId || "369102305";
  const region = p?.region || "EU West";
  const rankLabel = p?.rank || "Immortal";
  const kpi = (l: string) => data?.kpis?.find((k) => k.label === l)?.value;

  const ranks = data
    ? [
        { label: "GM Score", value: String(data.score?.value ?? "—"), mono: true },
        { label: "Winrate", value: kpi("Винрейт") || "—", mono: true },
        { label: "KDA", value: kpi("KDA") || "—", mono: true },
        { label: "Rank", value: rankLabel, mono: false },
      ]
    : [
        { label: "Peak MMR", value: "8 420", mono: true },
        { label: "Current MMR", value: "7 840", mono: true },
        { label: "Rank", value: "Immortal", mono: false },
        { label: "Hours", value: "6 200", mono: true },
      ];

  return (
    <div className="rounded-lg p-5 flex items-center gap-6 relative overflow-hidden"
      style={{ background: "#0B0E13", border: "1px solid #1B2430", boxShadow: "0 0 40px rgba(0,208,132,0.04)" }}>
      <div className="absolute inset-0 pointer-events-none"
        style={{ background: "radial-gradient(ellipse 400px 200px at 80% 50%, rgba(0,208,132,0.04) 0%, transparent 70%)" }} />

      <div className="relative shrink-0">
        <div className="w-20 h-20 rounded-xl overflow-hidden" style={{ border: "2px solid #1B2430" }}>
          <img src="https://images.unsplash.com/photo-1640951613773-54706e06851d?w=80&h=80&fit=crop&auto=format"
            alt="Player avatar" style={{ width: "100%", height: "100%", objectFit: "cover" }} />
        </div>
        <div className="absolute -bottom-1 -right-1 w-6 h-6 rounded-full flex items-center justify-center"
          style={{ background: "#00D084", border: "2px solid #080A0F" }}>
          <Trophy size={11} color="#050608" strokeWidth={2.5} />
        </div>
      </div>

      <div className="flex-1 min-w-0 relative z-10">
        <div className="flex items-center gap-2 mb-0.5">
          <span style={{ fontFamily: "Manrope, sans-serif", fontWeight: 800, fontSize: 20, color: "#F4F6FA", letterSpacing: "-0.4px" }}>{name}</span>
          <span className="px-1.5 py-0.5 rounded text-xs"
            style={{ background: "rgba(212,175,55,0.15)", color: "#D4AF37", fontFamily: "JetBrains Mono, monospace", fontSize: 10, fontWeight: 600, letterSpacing: "0.06em" }}>PRO</span>
          <a href="#" style={{ color: "#8A94A6" }}><ExternalLink size={13} /></a>
        </div>
        <div className="flex items-center gap-2 mb-4">
          <Shield size={12} color="#8A94A6" />
          <span style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 11, color: "#8A94A6" }}>{accountId}</span>
          <span style={{ color: "#1B2430" }}>·</span>
          <Clock size={12} color="#8A94A6" />
          <span style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 11, color: "#8A94A6" }}>{region}</span>
        </div>

        <div className="flex items-center gap-6 flex-wrap">
          {ranks.map(({ label, value, mono }) => (
            <div key={label}>
              <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 11, color: "#8A94A6", marginBottom: 2 }}>{label}</div>
              <div style={{ fontFamily: mono ? "JetBrains Mono, monospace" : "Manrope, sans-serif", fontWeight: 700, fontSize: 16, color: "#F4F6FA", letterSpacing: mono ? "0.02em" : "-0.3px" }}>{value}</div>
            </div>
          ))}
        </div>
      </div>

      <div className="shrink-0 flex flex-col items-center gap-2 px-5 py-4 rounded-lg relative z-10"
        style={{ background: "#111620", border: "1px solid #1B2430" }}>
        <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 10, color: "#8A94A6", letterSpacing: "0.08em" }}>RANK</div>
        <div className="w-14 h-14 rounded-full flex items-center justify-center"
          style={{ background: "linear-gradient(135deg, rgba(212,175,55,0.2), rgba(212,175,55,0.05))", border: "1px solid rgba(212,175,55,0.3)" }}>
          <Star size={24} color="#D4AF37" strokeWidth={1.5} />
        </div>
        <div style={{ fontFamily: "Manrope, sans-serif", fontWeight: 800, fontSize: 13, color: "#D4AF37" }}>{rankLabel}</div>
        <div style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 10, color: "#8A94A6" }}>{data ? region : "Top 2.1%"}</div>
      </div>
    </div>
  );
}
