import {
  LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip,
  ResponsiveContainer, Legend
} from "recharts";

const data = [
  { week: "W1", you: 61, miracle: 74, topson: 69, ammar: 72 },
  { week: "W2", you: 63, miracle: 76, topson: 71, ammar: 70 },
  { week: "W3", you: 58, miracle: 78, topson: 68, ammar: 73 },
  { week: "W4", you: 65, miracle: 75, topson: 72, ammar: 75 },
  { week: "W5", you: 64, miracle: 80, topson: 74, ammar: 71 },
  { week: "W6", you: 67, miracle: 77, topson: 76, ammar: 74 },
  { week: "W7", you: 70, miracle: 79, topson: 73, ammar: 77 },
  { week: "W8", you: 68, miracle: 81, topson: 78, ammar: 76 },
];

const lines = [
  { key: "you", label: "You", color: "#00D084", width: 2.5 },
  { key: "miracle", label: "Miracle-", color: "#3B82F6", width: 1.5 },
  { key: "topson", label: "Topson", color: "#A78BFA", width: 1.5 },
  { key: "ammar", label: "Ammar", color: "#F59E0B", width: 1.5 },
];

function CustomTooltip({ active, payload, label }: any) {
  if (!active || !payload?.length) return null;
  return (
    <div style={{
      background: "#111620",
      border: "1px solid #1B2430",
      borderRadius: 6,
      padding: "10px 14px",
    }}>
      <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 11, color: "#8A94A6", marginBottom: 6 }}>{label}</div>
      {payload.map((p: any) => (
        <div key={p.dataKey} className="flex items-center gap-2" style={{ marginBottom: 2 }}>
          <div className="w-2 h-2 rounded-full" style={{ background: p.color }} />
          <span style={{ fontFamily: "Manrope, sans-serif", fontSize: 11, color: p.dataKey === "you" ? "#F4F6FA" : "#8A94A6", fontWeight: p.dataKey === "you" ? 700 : 400 }}>
            {p.name}:
          </span>
          <span style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 11, color: p.color }}>{p.value}%</span>
        </div>
      ))}
    </div>
  );
}

export function ProComparison() {
  return (
    <div
      className="rounded-lg p-5"
      style={{ background: "#0B0E13", border: "1px solid #1B2430" }}
    >
      <div className="flex items-center justify-between mb-4">
        <div>
          <div style={{ fontFamily: "Manrope, sans-serif", fontWeight: 700, fontSize: 13, color: "#F4F6FA" }}>
            Pro Comparison
          </div>
          <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 11, color: "#8A94A6" }}>
            Win rate vs top Immortal players
          </div>
        </div>
        <div
          className="px-2.5 py-1 rounded"
          style={{ background: "rgba(0,208,132,0.1)", border: "1px solid rgba(0,208,132,0.2)", fontFamily: "JetBrains Mono, monospace", fontSize: 10, color: "#00D084" }}
        >
          8 weeks
        </div>
      </div>
      <ResponsiveContainer width="100%" height={200}>
        <LineChart data={data} margin={{ top: 4, right: 4, left: -20, bottom: 0 }}>
          <CartesianGrid stroke="#1B2430" strokeDasharray="3 3" vertical={false} />
          <XAxis
            dataKey="week"
            tick={{ fontFamily: "JetBrains Mono, monospace", fontSize: 9, fill: "#8A94A6" }}
            axisLine={false}
            tickLine={false}
          />
          <YAxis
            domain={[55, 85]}
            tick={{ fontFamily: "JetBrains Mono, monospace", fontSize: 9, fill: "#8A94A6" }}
            axisLine={false}
            tickLine={false}
          />
          <Tooltip content={<CustomTooltip />} />
          {lines.map(({ key, label, color, width }) => (
            <Line
              key={key}
              type="monotone"
              dataKey={key}
              name={label}
              stroke={color}
              strokeWidth={width}
              dot={false}
              activeDot={{ r: 4, fill: color }}
              strokeDasharray={key !== "you" ? "4 3" : undefined}
            />
          ))}
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}
