import { Info } from "lucide-react";
import { usePlayer } from "../../lib/store";

const PALETTE = ["#00D084", "#3B82F6", "#A78BFA", "#F59E0B", "#06B6D4", "#EC4899"];
const DEMO = [
  { label: "Farming", value: 82 },
  { label: "Fighting", value: 71 },
  { label: "Supporting", value: 55 },
  { label: "Pushing", value: 68 },
  { label: "Versatility", value: 78 },
];

function GaugeArc({ score }: { score: number }) {
  const r = 64, cx = 80, cy = 80, startAngle = -220, endAngle = 40;
  const totalArc = endAngle - startAngle;
  const filled = (score / 100) * totalArc;
  const polar = (angle: number, radius: number) => {
    const a = (angle * Math.PI) / 180;
    return { x: cx + radius * Math.cos(a), y: cy + radius * Math.sin(a) };
  };
  const arcPath = (from: number, to: number, radius: number) => {
    const p1 = polar(from, radius), p2 = polar(to, radius);
    const large = Math.abs(to - from) > 180 ? 1 : 0;
    return `M ${p1.x} ${p1.y} A ${radius} ${radius} 0 ${large} 1 ${p2.x} ${p2.y}`;
  };
  return (
    <svg width={160} height={120} viewBox="0 0 160 120">
      <path d={arcPath(startAngle, endAngle, r)} fill="none" stroke="#1B2430" strokeWidth={10} strokeLinecap="round" />
      <path d={arcPath(startAngle, startAngle + filled, r)} fill="none" stroke="url(#gaugeGrad)" strokeWidth={10} strokeLinecap="round" />
      <defs>
        <linearGradient id="gaugeGrad" x1="0%" y1="0%" x2="100%" y2="0%">
          <stop offset="0%" stopColor="#00A868" /><stop offset="100%" stopColor="#00D084" />
        </linearGradient>
      </defs>
      <circle cx={polar(startAngle + filled, r).x} cy={polar(startAngle + filled, r).y} r={5} fill="#00D084" style={{ filter: "drop-shadow(0 0 6px #00D084)" }} />
    </svg>
  );
}

function tier(score: number) {
  if (score >= 80) return "Elite";
  if (score >= 70) return "Expert";
  if (score >= 55) return "Skilled";
  return "Rising";
}

export function ScoreGauge() {
  const { data } = usePlayer();
  const score = data?.score?.value ?? 74;
  const skills = (data?.score?.breakdown && data.score.breakdown.length ? data.score.breakdown : DEMO)
    .map((s, i) => ({ label: s.label, value: s.value, color: PALETTE[i % PALETTE.length] }));

  return (
    <div className="rounded-lg p-5" style={{ background: "#0B0E13", border: "1px solid #1B2430" }}>
      <div className="flex items-center gap-1.5 relative group" style={{ marginBottom: 16, width: "fit-content" }}>
        <span style={{ fontFamily: "Manrope, sans-serif", fontWeight: 700, fontSize: 13, color: "#F4F6FA" }}>GameMentor Score</span>
        <Info size={13} color="#8A94A6" style={{ cursor: "help" }} />
        <div className="absolute left-0 top-full mt-2 z-30 opacity-0 pointer-events-none group-hover:opacity-100 transition-opacity"
          style={{ width: 280, background: "#10141B", border: "1px solid #1B2430", borderRadius: 10, padding: 12, boxShadow: "0 18px 40px -18px rgba(0,0,0,0.9)" }}>
          <div style={{ fontFamily: "Manrope, sans-serif", fontWeight: 700, fontSize: 12, color: "#F4F6FA", marginBottom: 6 }}>Как считается оценка</div>
          <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 11.5, color: "#8A94A6", lineHeight: 1.5 }}>
            Метрики окна (GPM, XPM, CS, урон…) переводятся в <b style={{ color: "#F4F6FA" }}>перцентили</b> относительно брекета через OpenDota benchmarks, плюс учитывается <b style={{ color: "#F4F6FA" }}>IMP</b> от Stratz. Из них собираются под-оценки:
          </div>
          <div style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 10.5, color: "#8A94A6", lineHeight: 1.7, marginTop: 6 }}>
            Overall = Фарм·30% + Бой·30% +<br />Объекты·15% + Стабильность·15% + Вижн·10%
          </div>
          <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 11, color: "#8A94A6", lineHeight: 1.5, marginTop: 6 }}>
            Стабильность — меньше смертей + винрейт. Чем выше перцентиль, тем выше балл.
          </div>
        </div>
      </div>
      <div className="flex flex-col items-center mb-4">
        <div className="relative">
          <GaugeArc score={score} />
          <div className="absolute inset-0 flex flex-col items-center justify-center" style={{ paddingTop: 8 }}>
            <div style={{ fontFamily: "JetBrains Mono, monospace", fontWeight: 700, fontSize: 32, color: "#F4F6FA", lineHeight: 1 }}>{score}</div>
            <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 10, color: "#8A94A6", marginTop: 2 }}>/ 100</div>
          </div>
        </div>
        <div className="px-2.5 py-1 rounded-full"
          style={{ background: "rgba(0,208,132,0.12)", border: "1px solid rgba(0,208,132,0.25)", fontFamily: "Manrope, sans-serif", fontWeight: 700, fontSize: 11, color: "#00D084" }}>{tier(score)}</div>
      </div>
      <div className="flex flex-col gap-2.5">
        {skills.map(({ label, value, color }) => (
          <div key={label}>
            <div className="flex justify-between mb-1">
              <span style={{ fontFamily: "Manrope, sans-serif", fontSize: 11, color: "#8A94A6" }}>{label}</span>
              <span style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 11, color: "#F4F6FA" }}>{value}</span>
            </div>
            <div className="h-1 rounded-full" style={{ background: "#1B2430" }}>
              <div className="h-1 rounded-full" style={{ width: `${value}%`, background: color, boxShadow: `0 0 6px ${color}60` }} />
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
