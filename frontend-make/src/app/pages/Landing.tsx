import { useRef } from "react";
import { useNavigate } from "react-router";
import { ArrowRight, LogIn, Gamepad2 } from "lucide-react";
import { usePlayer } from "../../lib/store";
import { useAuth } from "../../lib/auth";

// CTA words inside the landing that should funnel the user into the app.
const CTA_RE = /разобр|профил|анализ|начать|начни|попроб|дашборд|старт|войти|регистр|получить|узнать|оценить|try|get started|analyze|sign in|start/i;

// The marketing landing is a self-contained design served as a static file
// (frontend-make/public/landing.html). We render it in a full-screen iframe and
// overlay a small LIVE personalization bar (React → has access to our API/store),
// so a logged-in player sees their real account right away.
export default function Landing() {
  const nav = useNavigate();
  const { data } = usePlayer();
  const { user } = useAuth();

  const iframeRef = useRef<HTMLIFrameElement>(null);
  const base = (import.meta as any).env?.BASE_URL || "/";
  const landingUrl = base.replace(/\/$/, "") + "/landing.html";

  // The landing is a static design; its buttons aren't wired to our backend.
  // Intercept CTA clicks inside the (same-origin) iframe and route into the app.
  const onIframeLoad = () => {
    try {
      const doc = iframeRef.current?.contentDocument;
      if (!doc) return;
      doc.addEventListener(
        "click",
        (ev: any) => {
          const el = ev.target?.closest?.("a,button,[role=button]");
          if (!el) return;
          const txt = (el.textContent || "").trim().toLowerCase();
          if (CTA_RE.test(txt)) {
            ev.preventDefault();
            ev.stopPropagation();
            nav(/войти|sign in|регистр/.test(txt) ? "/login" : "/overview");
          }
        },
        true
      );
    } catch {
      /* cross-origin or not ready — ignore */
    }
  };

  const gmScore = data?.score?.value;
  const winrate = data?.kpis?.find((k: any) => /винрейт|winrate/i.test(k.label))?.value;

  return (
    <div style={{ position: "fixed", inset: 0, background: "#050608" }}>
      <iframe
        ref={iframeRef}
        src={landingUrl}
        title="GameMentor"
        onLoad={onIframeLoad}
        style={{ position: "absolute", inset: 0, width: "100%", height: "100%", border: "none", display: "block" }}
      />

      {/* LIVE personalization bar */}
      <div style={{
        position: "fixed", top: 0, left: 0, right: 0, zIndex: 10,
        display: "flex", alignItems: "center", gap: 14, padding: "10px 16px",
        background: "rgba(5,6,8,0.82)", backdropFilter: "blur(10px)",
        borderBottom: "1px solid #1B2430", fontFamily: "Manrope, sans-serif",
      }}>
        <div style={{ display: "flex", alignItems: "center", gap: 8, minWidth: 0 }}>
          <div style={{ width: 28, height: 28, borderRadius: 8, background: "linear-gradient(135deg,#00D084,#0AA968)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
            <Gamepad2 size={16} color="#04110B" />
          </div>
          <span style={{ fontWeight: 800, fontSize: 14, color: "#F4F6FA", whiteSpace: "nowrap" }}>GameMentor</span>
        </div>

        {user ? (
          <div className="hidden sm:flex" style={{ alignItems: "center", gap: 14, minWidth: 0, color: "#8A94A6", fontSize: 12.5 }}>
            <span style={{ color: "#F4F6FA", fontWeight: 600, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>
              С возвращением, {user.display_name || user.username}
            </span>
            {gmScore != null ? <span style={{ whiteSpace: "nowrap" }}>GM Score <b style={{ color: "#00D084" }}>{gmScore}</b></span> : null}
            {winrate ? <span style={{ whiteSpace: "nowrap" }}>Winrate <b style={{ color: "#F4F6FA" }}>{winrate}</b></span> : null}
          </div>
        ) : (
          <span className="hidden sm:inline" style={{ color: "#8A94A6", fontSize: 12.5 }}>Разбор твоего профиля Dota 2 с ИИ</span>
        )}

        <div style={{ marginLeft: "auto", display: "flex", gap: 8, flexShrink: 0 }}>
          {!user ? (
            <button onClick={() => nav("/login")}
              style={{ display: "inline-flex", alignItems: "center", gap: 6, background: "transparent", border: "1px solid #1B2430", color: "#F4F6FA", borderRadius: 9, padding: "8px 14px", cursor: "pointer", fontSize: 13, fontWeight: 600 }}>
              <LogIn size={14} /> Войти
            </button>
          ) : null}
          <button onClick={() => nav("/overview")}
            style={{ display: "inline-flex", alignItems: "center", gap: 6, background: "#00D084", border: "none", color: "#04110B", borderRadius: 9, padding: "8px 16px", cursor: "pointer", fontSize: 13, fontWeight: 800 }}>
            {user ? "Открыть дашборд" : "Открыть приложение"} <ArrowRight size={14} />
          </button>
        </div>
      </div>

      {/* Floating CTA bottom-right */}
      <button onClick={() => nav("/overview")}
        style={{ position: "fixed", right: 20, bottom: 20, zIndex: 10, display: "inline-flex", alignItems: "center", gap: 8, background: "#D4AF37", border: "none", color: "#050608", borderRadius: 14, padding: "13px 20px", cursor: "pointer", fontFamily: "Manrope, sans-serif", fontWeight: 800, fontSize: 14, boxShadow: "0 14px 34px -12px rgba(212,175,55,0.6)" }}>
        Перейти к разбору <ArrowRight size={16} />
      </button>
    </div>
  );
}
