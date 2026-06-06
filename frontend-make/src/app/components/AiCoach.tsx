import { Sparkles, ArrowRight, AlertTriangle, TrendingUp, Target } from "lucide-react";

const insights = [
  {
    icon: TrendingUp,
    type: "strength",
    color: "#00D084",
    bg: "rgba(0,208,132,0.08)",
    title: "Exceptional farm efficiency",
    body: "Your GPM ranks top 5% among Immortal carries. Prioritize radiant jungle rotations — you clear 18% faster than average.",
  },
  {
    icon: AlertTriangle,
    type: "weakness",
    color: "#F59E0B",
    bg: "rgba(245,158,11,0.08)",
    title: "Vision score below peers",
    body: "Your ward count is 4.2/game vs 6.8 average for your bracket. Boost observer usage in mid-game teamfights.",
  },
  {
    icon: Target,
    type: "focus",
    color: "#3B82F6",
    bg: "rgba(59,130,246,0.08)",
    title: "Hero pool consolidation",
    body: "57 heroes played this season. Narrowing to 8-10 signature picks would increase win rate by an estimated +4.2%.",
  },
];

export function AiCoach() {
  return (
    <div
      className="rounded-lg p-5 relative overflow-hidden"
      style={{
        background: "#0B0E13",
        border: "1px solid rgba(212,175,55,0.25)",
        boxShadow: "0 0 30px rgba(212,175,55,0.04)",
      }}
    >
      {/* Gold glow bg */}
      <div
        className="absolute top-0 right-0 w-48 h-48 pointer-events-none"
        style={{ background: "radial-gradient(circle, rgba(212,175,55,0.06) 0%, transparent 70%)" }}
      />

      <div className="flex items-center gap-2.5 mb-4 relative z-10">
        <div
          className="w-7 h-7 rounded-lg flex items-center justify-center"
          style={{ background: "rgba(212,175,55,0.15)", border: "1px solid rgba(212,175,55,0.25)" }}
        >
          <Sparkles size={14} color="#D4AF37" />
        </div>
        <div>
          <div style={{ fontFamily: "Manrope, sans-serif", fontWeight: 700, fontSize: 13, color: "#F4F6FA" }}>
            AI Coach
          </div>
          <div style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 9, color: "#D4AF37", letterSpacing: "0.06em" }}>
            POWERED BY GM-7
          </div>
        </div>
        <div
          className="ml-auto px-2 py-0.5 rounded-full"
          style={{ background: "rgba(212,175,55,0.12)", border: "1px solid rgba(212,175,55,0.2)", fontFamily: "Manrope, sans-serif", fontWeight: 600, fontSize: 10, color: "#D4AF37" }}
        >
          3 insights
        </div>
      </div>

      <div className="flex flex-col gap-3 relative z-10">
        {insights.map(({ icon: Icon, color, bg, title, body }) => (
          <div
            key={title}
            className="flex gap-3 p-3 rounded-lg"
            style={{ background: bg, border: `1px solid ${color}20` }}
          >
            <div className="mt-0.5 shrink-0">
              <Icon size={14} color={color} />
            </div>
            <div>
              <div style={{ fontFamily: "Manrope, sans-serif", fontWeight: 600, fontSize: 12, color: "#F4F6FA", marginBottom: 2 }}>
                {title}
              </div>
              <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 11, color: "#8A94A6", lineHeight: 1.5 }}>
                {body}
              </div>
            </div>
          </div>
        ))}
      </div>

      <button
        className="mt-4 w-full flex items-center justify-center gap-2 py-2 rounded-lg relative z-10 transition-all"
        style={{
          background: "rgba(212,175,55,0.1)",
          border: "1px solid rgba(212,175,55,0.25)",
          fontFamily: "Manrope, sans-serif",
          fontWeight: 600,
          fontSize: 12,
          color: "#D4AF37",
          cursor: "pointer",
        }}
      >
        Full coaching report
        <ArrowRight size={13} />
      </button>
    </div>
  );
}
