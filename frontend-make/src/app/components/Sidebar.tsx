import { NavLink, useNavigate } from "react-router";
import {
  BarChart2, Zap, Trophy, Settings, Gamepad2, Target,
  TrendingUp, BookOpen, Crown, Bomb, Dumbbell, LogIn, Database,
} from "lucide-react";
import { useAuth } from "../../lib/auth";

const DOTA_NAV = [
  { icon: BarChart2, label: "Overview", to: "/" },
  { icon: TrendingUp, label: "Performance", to: "/performance" },
  { icon: Target, label: "Heroes", to: "/heroes" },
  { icon: Trophy, label: "Rankings", to: "/rankings" },
  { icon: BookOpen, label: "Replays", to: "/replays" },
  { icon: Database, label: "Data Explorer", to: "/explorer" },
];

const CS2_NAV = [
  { icon: Bomb, label: "Grenades", to: "/cs2/grenades" },
  { icon: Dumbbell, label: "Training", to: "/cs2/training" },
];

export function Sidebar({ game = "dota" }: { game?: "dota" | "cs2" }) {
  const nav = useNavigate();
  const { user, subscription } = useAuth();
  const items = game === "cs2" ? CS2_NAV : DOTA_NAV;
  const accent = game === "cs2" ? "#FF6B00" : "#00D084";
  const plan = subscription?.plan || "free";
  const initials = (user?.display_name || user?.username || "U").slice(0, 2).toUpperCase();

  return (
    <aside className="hidden md:flex flex-col h-full w-[220px] shrink-0 border-r"
      style={{ background: "#080A0F", borderColor: "#1B2430" }}>
      {/* Logo */}
      <div className="px-5 py-5 border-b" style={{ borderColor: "#1B2430" }}>
        <div className="flex items-center gap-2.5">
          <div className="w-8 h-8 rounded-lg flex items-center justify-center"
            style={{ background: "linear-gradient(135deg, " + accent + " 0%, #00A868 100%)" }}>
            <Zap size={16} color="#050608" strokeWidth={2.5} />
          </div>
          <div>
            <div style={{ fontFamily: "Manrope, sans-serif", fontWeight: 800, fontSize: 15, color: "#F4F6FA", letterSpacing: "-0.3px" }}>GameMentor</div>
            <div style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 9, color: accent, letterSpacing: "0.08em" }}>PRO ANALYTICS</div>
          </div>
        </div>
      </div>

      {/* Game switcher */}
      <div className="px-4 py-3 border-b" style={{ borderColor: "#1B2430" }}>
        <div className="flex rounded-md overflow-hidden" style={{ background: "#111620", border: "1px solid #1B2430" }}>
          {([["dota", "DOTA 2", "/"], ["cs2", "CS2", "/cs2/grenades"]] as const).map(([g, lbl, to]) => (
            <button key={g} onClick={() => nav(to)}
              className="flex-1 flex items-center justify-center gap-1.5 py-1.5 transition-all"
              style={{
                fontFamily: "Manrope, sans-serif", fontWeight: 600, fontSize: 11, letterSpacing: "0.04em",
                background: game === g ? (g === "cs2" ? "#FF6B00" : "#00D084") : "transparent",
                color: game === g ? "#050608" : "#8A94A6", cursor: "pointer", border: "none",
              }}>
              <Gamepad2 size={12} />{lbl}
            </button>
          ))}
        </div>
      </div>

      {/* Nav */}
      <nav className="flex-1 px-3 py-3 flex flex-col gap-0.5 overflow-y-auto">
        {items.map(({ icon: Icon, label, to }) => (
          <NavLink key={label} to={to} end={to === "/"}
            className="flex items-center gap-3 px-3 py-2.5 rounded-lg w-full transition-all"
            style={({ isActive }) => ({
              fontFamily: "Manrope, sans-serif", fontWeight: isActive ? 600 : 500, fontSize: 13,
              background: isActive ? accent + "1a" : "transparent",
              color: isActive ? accent : "#8A94A6", textDecoration: "none",
            })}>
            <Icon size={16} />
            <span className="flex-1">{label}</span>
          </NavLink>
        ))}
      </nav>

      {/* Bottom */}
      <div className="px-3 py-3 border-t flex flex-col gap-0.5" style={{ borderColor: "#1B2430" }}>
        <button onClick={() => nav("/subscription")} className="flex items-center gap-3 px-3 py-2.5 rounded-lg w-full"
          style={{ fontFamily: "Manrope, sans-serif", fontWeight: 500, fontSize: 13, background: "transparent", color: plan === "free" ? "#8A94A6" : "#D4AF37", border: "none", cursor: "pointer", textAlign: "left" }}>
          <Crown size={16} />Подписка
        </button>
        <button onClick={() => nav("/profile")} className="flex items-center gap-3 px-3 py-2.5 rounded-lg w-full"
          style={{ fontFamily: "Manrope, sans-serif", fontWeight: 500, fontSize: 13, background: "transparent", color: "#8A94A6", border: "none", cursor: "pointer", textAlign: "left" }}>
          <Settings size={16} />Профиль и настройки
        </button>

        {user ? (
          <button onClick={() => nav("/profile")} className="mt-2 flex items-center gap-3 px-3 py-2.5 rounded-lg w-full"
            style={{ background: "#111620", border: "none", cursor: "pointer", textAlign: "left" }}>
            <div className="w-7 h-7 rounded-full flex items-center justify-center shrink-0 overflow-hidden"
              style={{ background: "linear-gradient(135deg, #3B82F6, #8B5CF6)", fontSize: 11, fontWeight: 700, color: "#fff", fontFamily: "Manrope, sans-serif" }}>
              {user.avatar_url ? <img src={user.avatar_url} alt="" style={{ width: "100%", height: "100%", objectFit: "cover" }} /> : initials}
            </div>
            <div className="flex-1 min-w-0">
              <div style={{ fontFamily: "Manrope, sans-serif", fontWeight: 600, fontSize: 12, color: "#F4F6FA", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{user.display_name || user.username}</div>
              <div style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 10, color: plan === "free" ? "#8A94A6" : "#D4AF37" }}>{plan.toUpperCase()}</div>
            </div>
          </button>
        ) : (
          <button onClick={() => nav("/login")} className="mt-2 flex items-center justify-center gap-2 px-3 py-2.5 rounded-lg w-full"
            style={{ background: accent, border: "none", cursor: "pointer", fontFamily: "Manrope, sans-serif", fontWeight: 700, fontSize: 13, color: "#04110B" }}>
            <LogIn size={15} />Войти / Регистрация
          </button>
        )}
      </div>
    </aside>
  );
}
