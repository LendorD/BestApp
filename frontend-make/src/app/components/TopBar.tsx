import { useState, useRef, useEffect } from "react";
import { useNavigate } from "react-router";
import { Search, Bell, RefreshCw, Loader2, LogIn, User as UserIcon, Crown, LogOut, Info, ArrowLeft } from "lucide-react";
import { usePlayer } from "../../lib/store";
import { useAuth } from "../../lib/auth";

export function TopBar() {
  const nav = useNavigate();
  const { search, loading, live, error, viewingSelf, resetToSelf } = usePlayer();
  const { user, subscription, logout } = useAuth();
  const [q, setQ] = useState("");
  const [focused, setFocused] = useState(false);
  const [menu, setMenu] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);

  const go = async () => {
    if (!q.trim()) return;
    await search(q);
    nav("/");
  };

  useEffect(() => {
    const onClick = (e: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(e.target as Node)) setMenu(false);
    };
    document.addEventListener("mousedown", onClick);
    return () => document.removeEventListener("mousedown", onClick);
  }, []);

  const plan = subscription?.plan || "free";
  const initials = (user?.display_name || user?.username || "U").slice(0, 2).toUpperCase();

  return (
    <header className="flex items-center justify-between px-4 sm:px-6 h-14 shrink-0 border-b relative"
      style={{ background: "#080A0F", borderColor: "#1B2430" }}>
      <div className="flex items-center gap-3 min-w-0 flex-1">
        <div className="relative w-full" style={{ maxWidth: 360 }}>
          <div className="flex items-center gap-2 px-3 py-1.5 rounded-lg w-full"
            style={{ background: "#111620", border: "1px solid " + (error ? "#FF4560" : focused ? "#00D084" : "#1B2430") }}>
            {loading ? <Loader2 size={14} color="#00D084" className="animate-spin" /> : <Search size={14} color="#8A94A6" />}
            <input
              value={q}
              onChange={(e) => setQ(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && go()}
              onFocus={() => setFocused(true)}
              onBlur={() => setTimeout(() => setFocused(false), 150)}
              placeholder="Steam-ссылка, SteamID или Dota ID…"
              style={{ background: "transparent", border: "none", outline: "none", fontFamily: "Manrope, sans-serif", fontSize: 13, color: "#F4F6FA", width: "100%" }}
            />
          </div>
          {focused && (
            <div className="absolute left-0 right-0 mt-2 rounded-lg p-3 z-20"
              style={{ background: "#0B0E13", border: "1px solid #1B2430", boxShadow: "0 18px 40px -18px rgba(0,0,0,0.9)" }}>
              <div className="flex items-center gap-2 mb-2" style={{ fontFamily: "Manrope, sans-serif", fontSize: 11, fontWeight: 700, color: "#8A94A6", letterSpacing: "0.04em" }}>
                <Info size={12} color="#00D084" /> ЧТО МОЖНО ВСТАВИТЬ
              </div>
              {[
                ["Ссылку на профиль Steam", "steamcommunity.com/id/Goshamoshen"],
                ["SteamID64", "76561198000000000"],
                ["Dota Friend / Account ID", "369102305"],
              ].map(([t, ex]) => (
                <div key={t} className="flex items-baseline justify-between gap-3 py-1">
                  <span style={{ fontFamily: "Manrope, sans-serif", fontSize: 12.5, color: "#F4F6FA" }}>{t}</span>
                  <span style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 11, color: "#8A94A6", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", maxWidth: 180 }}>{ex}</span>
                </div>
              ))}
            </div>
          )}
        </div>
        {!viewingSelf && user?.dota_account_id ? (
          <button onClick={resetToSelf}
            className="hidden sm:flex items-center gap-1.5 rounded-lg px-2.5 py-1.5 shrink-0"
            style={{ background: "#111620", border: "1px solid #1B2430", cursor: "pointer", fontFamily: "Manrope, sans-serif", fontSize: 12, color: "#00D084", fontWeight: 600 }}>
            <ArrowLeft size={13} /> Мои данные
          </button>
        ) : null}
        {error ? <span style={{ fontFamily: "Manrope, sans-serif", fontSize: 11, color: "#FF4560" }} className="hidden lg:inline">{error}</span> : null}
      </div>

      <div className="flex items-center gap-3">
        <div className="hidden sm:flex items-center gap-1.5" style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 11, color: "#8A94A6" }}>
          <span style={{ width: 7, height: 7, borderRadius: 999, background: live ? "#00D084" : "#8A94A6", boxShadow: live ? "0 0 6px #00D084" : "none" }} />
          {live ? "LIVE · OpenDota" : "DEMO"}
        </div>
        <button className="p-2 rounded-lg" style={{ background: "#111620", border: "1px solid #1B2430", cursor: "pointer" }}>
          <RefreshCw size={14} color="#8A94A6" />
        </button>
        <button className="p-2 rounded-lg relative" style={{ background: "#111620", border: "1px solid #1B2430", cursor: "pointer" }}>
          <Bell size={14} color="#8A94A6" />
          <span className="absolute top-1.5 right-1.5 w-1.5 h-1.5 rounded-full" style={{ background: "#00D084" }} />
        </button>

        {user ? (
          <div className="relative" ref={menuRef}>
            <button onClick={() => setMenu((m) => !m)} className="w-8 h-8 rounded-full flex items-center justify-center overflow-hidden"
              style={{ background: "linear-gradient(135deg, #3B82F6, #8B5CF6)", fontFamily: "Manrope, sans-serif", fontWeight: 700, fontSize: 12, color: "#fff", cursor: "pointer", border: plan !== "free" ? "2px solid #D4AF37" : "none" }}>
              {user.avatar_url ? <img src={user.avatar_url} alt="" style={{ width: "100%", height: "100%", objectFit: "cover" }} /> : initials}
            </button>
            {menu && (
              <div className="absolute right-0 mt-2 rounded-lg py-2 z-30" style={{ minWidth: 200, background: "#0B0E13", border: "1px solid #1B2430", boxShadow: "0 18px 40px -18px rgba(0,0,0,0.9)" }}>
                <div className="px-3 pb-2 mb-1" style={{ borderBottom: "1px solid #1B2430" }}>
                  <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 13, fontWeight: 700, color: "#F4F6FA", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{user.display_name || user.username}</div>
                  <div style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 10.5, color: plan === "free" ? "#8A94A6" : "#D4AF37" }}>{plan.toUpperCase()} PLAN</div>
                </div>
                <MenuItem icon={<UserIcon size={14} />} label="Профиль" onClick={() => { setMenu(false); nav("/profile"); }} />
                <MenuItem icon={<Crown size={14} />} label="Подписка" onClick={() => { setMenu(false); nav("/subscription"); }} />
                <MenuItem icon={<LogOut size={14} />} label="Выйти" danger onClick={() => { setMenu(false); logout(); nav("/login"); }} />
              </div>
            )}
          </div>
        ) : (
          <button onClick={() => nav("/login")}
            className="flex items-center gap-2 rounded-lg px-3 py-1.5"
            style={{ background: "#00D084", border: "none", cursor: "pointer", fontFamily: "Manrope, sans-serif", fontSize: 13, fontWeight: 700, color: "#04110B" }}>
            <LogIn size={14} /> Войти
          </button>
        )}
      </div>
    </header>
  );
}

function MenuItem({ icon, label, onClick, danger }: { icon: any; label: string; onClick: () => void; danger?: boolean }) {
  return (
    <button onClick={onClick} className="flex items-center gap-2.5 w-full px-3 py-2"
      style={{ background: "transparent", border: "none", cursor: "pointer", fontFamily: "Manrope, sans-serif", fontSize: 13, color: danger ? "#FF4560" : "#F4F6FA", textAlign: "left" }}
      onMouseEnter={(e) => (e.currentTarget.style.background = "#111620")}
      onMouseLeave={(e) => (e.currentTarget.style.background = "transparent")}>
      <span style={{ color: danger ? "#FF4560" : "#8A94A6" }}>{icon}</span> {label}
    </button>
  );
}
