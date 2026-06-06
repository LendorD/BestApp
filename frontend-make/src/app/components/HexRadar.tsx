import { Radar, RadarChart, PolarGrid, PolarAngleAxis, ResponsiveContainer, Tooltip } from "recharts";
import { usePlayer } from "../../lib/store";

const DEMO = [
  { skill: "Farming", value: 82 }, { skill: "Fighting", value: 71 }, { skill: "Vision", value: 64 },
  { skill: "Pushing", value: 68 }, { skill: "Saving", value: 55 }, { skill: "Versatility", value: 78 },
];

export function HexRadar() {
  const { data } = usePlayer();
  const chartData = data?.radar && data.radar.length
    ? data.radar.map((r) => ({ skill: r.axis, value: r.value }))
    : DEMO;

  return (
    <div className="rounded-lg p-5" style={{ background: "#0B0E13", border: "1px solid #1B2430" }}>
      <div style={{ fontFamily: "Manrope, sans-serif", fontWeight: 700, fontSize: 13, color: "#F4F6FA", marginBottom: 8 }}>Skill Radar</div>
      <ResponsiveContainer width="100%" height={220}>
        <RadarChart data={chartData} margin={{ top: 10, right: 20, bottom: 10, left: 20 }}>
          <PolarGrid stroke="#1B2430" />
          <PolarAngleAxis dataKey="skill" tick={{ fontFamily: "Manrope, sans-serif", fontSize: 10, fill: "#8A94A6" }} />
          <Tooltip contentStyle={{ background: "#111620", border: "1px solid #1B2430", borderRadius: 6, fontFamily: "JetBrains Mono, monospace", fontSize: 11, color: "#F4F6FA" }} />
          <Radar dataKey="value" stroke="#00D084" fill="#00D084" fillOpacity={0.12} strokeWidth={2} />
        </RadarChart>
      </ResponsiveContainer>
    </div>
  );
}
