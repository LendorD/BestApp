import { useRef, useState, useEffect } from "react";
import { useNavigate } from "react-router";
import { ArrowRight, LogIn, Gamepad2, Search, Loader2, Medal, X } from "lucide-react";
import { usePlayer } from "../../lib/store";
import { useAuth } from "../../lib/auth";
import { dota } from "../../lib/api";

const MEDALS = ["", "Herald", "Guardian", "Crusader", "Archon", "Legend", "Ancient", "Divine", "Immortal"];
function rankFromTier(t?: number) {
  if (!t || t <= 0) return "";
  const m = Math.floor(t / 10), s = t % 10, n = MEDALS[m] || "";
  return n ? (m >= 8 ? n : n + (s ? " " + s : "")) : "";
}

// The marketing landing is a self-contained static design (public/landing.html).
// We render it full-screen and overlay a REAL search + live preview so the
// player sees their own recalculated stats right here, without leaving.
export default function Landing() {
  const nav = useNavigate();
  const { search, accountId, loading, error } = usePlayer();
  const { user } = useAuth();
  const iframeRef = useRef<HTMLIFrameElement>(null);

  const [q, setQ] = useState("");
  const [prof, setProf] = useState<any>(null);
  const [report, setReport] = useState<any>(null);
  const [show, setShow] = useState(false);

  const base = (import.meta as any).env?.BASE_URL || "/";
  const landingUrl = base.replace(/\/$/, "") + "/landing.html";

  // Load real preview data whenever an account becomes active.
  useEffect(() => {
    if (!accountId) { setProf(null); setReport(null); return; }
    let cancelled = false;
    setShow(true);
    dota.profile(accountId).then((r: any) => { if (!cancelled) setProf(r); }).catch(() => {});
    dota.metrics(accountId, { limit: 50 }).then((r: any) => { if (!cancelled) setReport(r); }).catch(() => {});
    return () => { cancelled = true; };
  }, [accountId]);

  const go = async () => {
    if (!q.trim()) return;
    setShow(true);
    await search(q); // resolves steam-link / id and loads the player into the store
  };

  const name = prof?.persona_name || prof?.personaname || (accountId ? "Player " + accountId : "");
  const avatar = prof?.avatar_full || prof?.avatarfull || prof?.avatar || "";
  const rank = prof?.rank_label || rankFromTier(prof?.rank_tier) || "—";
  const metric = (k: string) => report?.metrics?.find((m: any) => m.key === k)?.value;

  const tiles = [
    { label: "GM Score", value: report?.scores?.overall ?? "…" },
    { label: "Winrate", value: report?.winrate_pct != null ? Math.round(report.winrate_pct) + "%" : "…" },
    { label: "KDA", value: metric("kda") ?? "…" },
    { label: "GPM", value: metric("gpm") ?? "…" },
    { label: "Матчей", value: report?.games ?? "…" },
  ];

  return (
    <div style={{ position: "fixed", inset: 0, background: "#050608", fontFamily: "Manrope, sans-serif" }}>
      <iframe ref={iframeRef} src={landingUrl} title="GameMentor"
        style={{ position: "absolute", inset: 0, width: "100%", height: "100%", border: "none", display: "block" }} />

      {/* Top bar with REAL search */}
      <div style={{ position: "fixed", top: 0, left: 0, right: 0, zIndex: 10, display: "flex", alignItems: "center", gap: 12, padding: "10px 16px", background: "rgba(5,6,8,0.86)", backdropFilter: "blur(10px)", borderBottom: "1px solid #1B2430" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 8, flexShrink: 0 }}>
          <div style={{ width: 28, height: 28, borderRadius: 8, background: "linear-gradient(135deg,#00D084,#0AA968)", display: "flex", alignItems: "center", justifyContent: "center" }}>
            <Gamepad2 size={16} color="#04110B" />
          </div>
          <span style={{ fontWeight: 800, fontSize: 14, color: "#F4F6FA" }} className="hidden sm:inline">GameMentor</span>
        </div>

        <div style={{ display: "flex", alignItems: "center", gap: 8, flex: 1, maxWidth: 460, background: "#111620", border: "1px solid " + (error ? "#FF4560" : "#1B2430"), borderRadius: 10, padding: "8px 12px" }}>
          {loading ? <Loader2 size={15} className="animate-spin" color="#00D084" /> : <Search size={15} color="#8A94A6" />}
          <input value={q} onChange={(e) => setQ(e.target.value)} onKeyDown={(e) => e.key === "Enter" && go()}
            placeholder="Steam-ссылка, SteamID или Dota ID…"
            style={{ background: "transparent", border: "none", outline: "none", color: "#F4F6FA", fontSize: 13, width: "100%", fontFamily: "Manrope, sans-serif" }} />
          <button onClick={go} style={{ background: "#00D084", color: "#04110B", border: "none", borderRadius: 7, padding: "6px 12px", cursor: "pointer", fontWeight: 800, fontSize: 12, flexShrink: 0 }}>Разобрать</button>
        </div>

        <div style={{ marginLeft: "auto", display: "flex", gap: 8, flexShrink: 0 }}>
          {!user ? (
            <button onClick={() => nav("/login")} style={{ display: "inline-flex", alignItems: "center", gap: 6, background: "transparent", border: "1px solid #1B2430", color: "#F4F6FA", borderRadius: 9, padding: "8px 14px", cursor: "pointer", fontSize: 13, fontWeight: 600 }} className="hidden sm:inline-flex">
              <LogIn size={14} /> Войти
            </button>
          ) : null}
          <button onClick={() => nav("/overview")} style={{ display: "inline-flex", alignItems: "center", gap: 6, background: "#111620", border: "1px solid #1B2430", color: "#F4F6FA", borderRadius: 9, padding: "8px 14px", cursor: "pointer", fontSize: 13, fontWeight: 700 }}>
            Полный дашборд <ArrowRight size={14} />
          </button>
        </div>
      </div>

      {/* Error */}
      {error ? (
        <div style={{ position: "fixed", top: 64, left: "50%", transform: "translateX(-50%)", zIndex: 11, background: "rgba(255,69,96,0.12)", border: "1px solid #FF4560", color: "#FF4560", borderRadius: 10, padding: "8px 14px", fontSize: 13 }}>{error}</div>
      ) : null}

      {/* LIVE preview card — real recalculated data, right on the landing */}
      {show && accountId ? (
        <div style={{ position: "fixed", top: 70, left: "50%", transform: "translateX(-50%)", zIndex: 11, width: "min(680px, calc(100% - 24px))", background: "#0B0E13", border: "1px solid #161C26", borderRadius: 18, boxShadow: "0 30px 70px -28px rgba(0,0,0,0.9)", overflow: "hidden" }}>
          <div style={{ display: "flex", alignItems: "center", gap: 16, padding: 18 }}>
            <div style={{ width: 64, height: 64, borderRadius: 16, overflow: "hidden", border: "2px solid #00D08455", flexShrink: 0 }}>
              {avatar ? <img src={avatar} alt="" style={{ width: "100%", height: "100%", objectFit: "cover" }} /> :
                <div style={{ width: "100%", height: "100%", background: "linear-gradient(135deg,#3B82F6,#8B5CF6)", display: "flex", alignItems: "center", justifyContent: "center", color: "#fff", fontWeight: 800, fontSize: 22 }}>{(name || "?").slice(0, 2).toUpperCase()}</div>}
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                <span style={{ fontWeight: 800, fontSize: 19, color: "#F4F6FA", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{loading && !name ? "Загрузка…" : (name || "—")}</span>
                <span style={{ display: "inline-flex", alignItems: "center", gap: 4, fontSize: 11.5, color: "#D4AF37" }}><Medal size={13} /> {rank}</span>
              </div>
              <div style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 11, color: "#8A94A6", marginTop: 2 }}>ID {accountId}</div>
            </div>
            <button onClick={() => setShow(false)} style={{ background: "transparent", border: "none", color: "#8A94A6", cursor: "pointer", flexShrink: 0 }}><X size={18} /></button>
          </div>

          <div style={{ display: "grid", gridTemplateColumns: "repeat(5, 1fr)", gap: 1, background: "#161C26" }}>
            {tiles.map((t) => (
              <div key={t.label} style={{ background: "#0B0E13", padding: "12px 8px", textAlign: "center" }}>
                <div style={{ fontFamily: "JetBrains Mono, monospace", fontWeight: 700, fontSize: 18, color: "#F4F6FA" }}>{String(t.value)}</div>
                <div style={{ fontSize: 10.5, color: "#8A94A6", marginTop: 2 }}>{t.label}</div>
              </div>
            ))}
          </div>

          <div style={{ padding: 14, display: "flex", gap: 10 }}>
            <button onClick={() => nav("/overview")} style={{ flex: 1, display: "inline-flex", alignItems: "center", justifyContent: "center", gap: 8, background: "#00D084", color: "#04110B", border: "none", borderRadius: 11, padding: "12px 0", cursor: "pointer", fontWeight: 800, fontSize: 14 }}>
              Полный разбор <ArrowRight size={15} />
            </button>
            <button onClick={() => nav("/coach")} style={{ display: "inline-flex", alignItems: "center", justifyContent: "center", gap: 8, background: "rgba(212,175,55,0.12)", color: "#D4AF37", border: "1px solid rgba(212,175,55,0.3)", borderRadius: 11, padding: "12px 18px", cursor: "pointer", fontWeight: 700, fontSize: 14 }}>
              AI-план
            </button>
          </div>
        </div>
      ) : null}
    </div>
  );
}
