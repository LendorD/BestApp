import {
  LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip,
  ResponsiveContainer, ReferenceLine,
} from "recharts";
import { usePlayer } from "../../lib/store";

const DEMO = [
  { date: "May 1", winrate: 58, kda: 3.8 }, { date: "May 5", winrate: 61, kda: 4.1 },
  { date: "May 9", winrate: 55, kda: 3.5 }, { date: "May 13", winrate: 63, kda: 4.4 },
  { date: "May 17", winrate: 60, kda: 4.2 }, { date: "May 21", winrate: 65, kda: 4.7 },
  { date: "May 25", winrate: 62, kda: 4.5 }, { date: "May 29", winrate: 68, kda: 5.0 },
  { date: "Jun 2", winrate: 64, kda: 4.8 }, { date: "Jun 5", winrate: 67, kda: 5.1 },
];

function CustomTooltip({ active, payload, label }: any) {
  if (!active || !payload?.length) return null;
  return (
    <div style={{ background: "#111620", border: "1px solid #1B2430", borderRadius: 6, padding: "8px 12px", fontFamily: "JetBrains Mono, monospace", fontSize: 11 }}>
      <div style={{ color: "#8A94A6", marginBottom: 4 }}>{label}</div>
      {payload.map((p: any) => (
        <div key={p.name} style={{ color: p.color }}>{p.name === "winrate" ? "WR" : "KDA"}: {p.value}{p.name === "winrate" ? "%" : ""}</div>
      ))}
    </div>
  );
}

export function PerformanceTrend() {
  const { data } = usePlayer();
  const chartData = data?.trend && data.trend.length >= 2 ? data.trend : DEMO;

  return (
    <div className="rounded-lg p-5" style={{ background: "#0B0E13", border: "1px solid #1B2430" }}>
      <div className="flex items-center justify-between mb-4">
        <div style={{ fontFamily: "Manrope, sans-serif", fontWeight: 700, fontSize: 13, color: "#F4F6FA" }}>Performance Trend</div>
        <div className="flex items-center gap-4">
          <div className="flex items-center gap-1.5"><div className="w-3 h-0.5 rounded" style={{ background: "#00D084" }} /><span style={{ fontFamily: "Manrope, sans-serif", fontSize: 11, color: "#8A94A6" }}>Win Rate</span></div>
          <div className="flex items-center gap-1.5"><div className="w-3 h-0.5 rounded" style={{ background: "#3B82F6" }} /><span style={{ fontFamily: "Manrope, sans-serif", fontSize: 11, color: "#8A94A6" }}>KDA × 10</span></div>
        </div>
      </div>
      <ResponsiveContainer width="100%" height={260}>
        <LineChart data={chartData} margin={{ top: 4, right: 4, left: -20, bottom: 0 }}>
          <CartesianGrid stroke="#1B2430" strokeDasharray="3 3" vertical={false} />
          <XAxis dataKey="date" tick={{ fontFamily: "JetBrains Mono, monospace", fontSize: 9, fill: "#8A94A6" }} axisLine={false} tickLine={false} />
          <YAxis tick={{ fontFamily: "JetBrains Mono, monospace", fontSize: 9, fill: "#8A94A6" }} axisLine={false} tickLine={false} />
          <ReferenceLine y={50} stroke="#1B2430" strokeDasharray="4 4" />
          <Tooltip content={<CustomTooltip />} />
          <Line type="monotone" dataKey="winrate" stroke="#00D084" strokeWidth={2} dot={false} activeDot={{ r: 4, fill: "#00D084" }} />
          <Line type="monotone" dataKey="kda" stroke="#3B82F6" strokeWidth={2} dot={false} activeDot={{ r: 4, fill: "#3B82F6" }} />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}
