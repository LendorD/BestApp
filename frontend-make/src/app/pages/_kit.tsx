import { ReactNode } from "react";

export const C = {
  bg: "#050608", card: "#0B0E13", surf: "#111620", border: "#1B2430",
  text: "#F4F6FA", muted: "#8A94A6", green: "#00D084", gold: "#D4AF37",
  blue: "#3B82F6", red: "#FF4560", purple: "#A78BFA",
};

export function Panel({ children, style, className = "" }: { children: ReactNode; style?: any; className?: string }) {
  return (
    <div className={"rounded-xl p-5 " + className}
      style={{ background: C.card, border: "1px solid " + C.border, ...style }}>
      {children}
    </div>
  );
}

export function SectionTitle({ title, sub, right }: { title: ReactNode; sub?: string; right?: ReactNode }) {
  return (
    <div className="flex items-end justify-between gap-3 mb-4">
      <div>
        <div style={{ fontFamily: "Manrope, sans-serif", fontWeight: 700, fontSize: 15, color: C.text, letterSpacing: "-0.2px" }}>{title}</div>
        {sub && <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 12, color: C.muted, marginTop: 3 }}>{sub}</div>}
      </div>
      {right}
    </div>
  );
}

export function Pill({ children, color = C.green }: { children: ReactNode; color?: string }) {
  return (
    <span style={{
      fontFamily: "JetBrains Mono, monospace", fontSize: 10.5, fontWeight: 600, letterSpacing: "0.06em",
      padding: "4px 9px", borderRadius: 6, color, background: color + "16", border: "1px solid " + color + "40",
      display: "inline-flex", alignItems: "center", gap: 6,
    }}>{children}</span>
  );
}

/** Marketing / selling block used on top of feature pages. */
export function SellBlock({ kicker, title, text, bullets = [], accent = C.green, cta }: {
  kicker: string; title: string; text: string; bullets?: string[]; accent?: string; cta?: string;
}) {
  return (
    <div className="rounded-xl p-6 relative overflow-hidden"
      style={{ background: C.card, border: "1px solid " + accent + "3a" }}>
      <div style={{ position: "absolute", inset: 0, pointerEvents: "none",
        background: "radial-gradient(120% 140% at 100% 0%, " + accent + "1f, transparent 55%)" }} />
      <div className="relative">
        <Pill color={accent}>{kicker}</Pill>
        <div style={{ fontFamily: "Manrope, sans-serif", fontWeight: 800, fontSize: 24, color: C.text, letterSpacing: "-0.5px", margin: "12px 0 8px", maxWidth: 640, lineHeight: 1.2 }}>{title}</div>
        <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 14, color: C.muted, maxWidth: 640, lineHeight: 1.6 }}>{text}</div>
        {bullets.length > 0 && (
          <div className="grid gap-2 mt-4" style={{ gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))" }}>
            {bullets.map((b) => (
              <div key={b} className="flex items-start gap-2">
                <span style={{ width: 6, height: 6, borderRadius: 999, background: accent, marginTop: 7, flexShrink: 0 }} />
                <span style={{ fontFamily: "Manrope, sans-serif", fontSize: 13, color: C.text, lineHeight: 1.5 }}>{b}</span>
              </div>
            ))}
          </div>
        )}
        {cta && (
          <button className="mt-5" style={{
            fontFamily: "Manrope, sans-serif", fontWeight: 700, fontSize: 13, color: C.bg,
            background: accent, border: "none", borderRadius: 8, padding: "10px 18px", cursor: "pointer",
          }}>{cta}</button>
        )}
      </div>
    </div>
  );
}

export function Meter({ value, color = C.green }: { value: number; color?: string }) {
  return (
    <div style={{ width: "100%", height: 6, background: C.surf, borderRadius: 999, overflow: "hidden" }}>
      <div style={{ width: Math.max(0, Math.min(100, value)) + "%", height: "100%", background: color, borderRadius: 999 }} />
    </div>
  );
}
