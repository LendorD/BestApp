import { useEffect, useState } from "react";
import { useNavigate } from "react-router";
import { Loader2, Check, Link2, LogOut, Crown } from "lucide-react";
import { Panel, SectionTitle, Pill, C } from "./_kit";
import { useAuth } from "../../lib/auth";

const field: React.CSSProperties = {
  background: C.surf, border: "1px solid " + C.border, borderRadius: 9,
  padding: "10px 12px", color: C.text, fontFamily: "Manrope, sans-serif",
  fontSize: 13.5, width: "100%", outline: "none",
};
const label: React.CSSProperties = { fontFamily: "Manrope, sans-serif", fontSize: 12, color: C.muted, marginBottom: 6, display: "block" };

export default function Profile() {
  const { user, subscription, ready, updateProfile, logout } = useAuth();
  const nav = useNavigate();
  const [form, setForm] = useState({ display_name: "", avatar_url: "", bio: "", favorite_game: "dota", dota_account_id: "" });
  const [busy, setBusy] = useState(false);
  const [saved, setSaved] = useState(false);
  const [err, setErr] = useState("");

  useEffect(() => {
    if (ready && !user) nav("/login", { replace: true, state: { from: "/profile" } });
  }, [ready, user, nav]);

  useEffect(() => {
    if (user) setForm({
      display_name: user.display_name || "",
      avatar_url: user.avatar_url || "",
      bio: user.bio || "",
      favorite_game: user.favorite_game || "dota",
      dota_account_id: user.dota_account_id ? String(user.dota_account_id) : "",
    });
  }, [user]);

  if (!user) return <div style={{ padding: 40, color: C.muted }}>Загрузка…</div>;

  const upd = (k: string) => (e: any) => setForm((f) => ({ ...f, [k]: e.target.value }));

  const useLastSearched = () => {
    try { const id = localStorage.getItem("gm.dotaId"); if (id) setForm((f) => ({ ...f, dota_account_id: id })); } catch { /* ignore */ }
  };

  const save = async () => {
    setErr(""); setBusy(true); setSaved(false);
    try {
      await updateProfile({
        display_name: form.display_name,
        avatar_url: form.avatar_url,
        bio: form.bio,
        favorite_game: form.favorite_game,
        dota_account_id: form.dota_account_id ? Number(form.dota_account_id) : undefined,
      });
      setSaved(true);
      setTimeout(() => setSaved(false), 2500);
    } catch (e: any) {
      setErr(e?.message || "Не удалось сохранить");
    } finally {
      setBusy(false);
    }
  };

  const plan = subscription?.plan || "free";
  const initials = (user.display_name || user.username || "U").slice(0, 2).toUpperCase();

  return (
    <div className="flex flex-col gap-4">
      <Panel>
        <div className="flex items-center gap-4 flex-wrap">
          <div style={{ width: 64, height: 64, borderRadius: 16, overflow: "hidden", background: "linear-gradient(135deg,#3B82F6,#8B5CF6)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
            {user.avatar_url ? <img src={user.avatar_url} alt="" style={{ width: "100%", height: "100%", objectFit: "cover" }} /> :
              <span style={{ fontWeight: 800, fontSize: 22, color: "#fff" }}>{initials}</span>}
          </div>
          <div style={{ minWidth: 0, flex: 1 }}>
            <div style={{ fontSize: 19, fontWeight: 800, color: C.text }}>{user.display_name || user.username}</div>
            <div style={{ fontSize: 12.5, color: C.muted }}>@{user.username} · {user.email}</div>
          </div>
          <Pill color={plan === "free" ? C.muted : C.gold}><Crown size={11} /> {plan.toUpperCase()}</Pill>
          <button onClick={() => { logout(); nav("/login", { replace: true }); }}
            style={{ display: "inline-flex", alignItems: "center", gap: 7, background: C.surf, border: "1px solid " + C.border, color: C.muted, borderRadius: 9, padding: "9px 13px", cursor: "pointer", fontFamily: "Manrope, sans-serif", fontSize: 13, fontWeight: 600 }}>
            <LogOut size={14} /> Выйти
          </button>
        </div>
      </Panel>

      <Panel>
        <SectionTitle title="Профиль" sub="Эти данные сохраняются на сервере" />
        <div className="grid gap-4" style={{ gridTemplateColumns: "repeat(auto-fit, minmax(240px, 1fr))" }}>
          <div>
            <label style={label}>Отображаемое имя</label>
            <input style={field} value={form.display_name} onChange={upd("display_name")} placeholder="Ваше имя" />
          </div>
          <div>
            <label style={label}>Любимая игра</label>
            <select style={field} value={form.favorite_game} onChange={upd("favorite_game")}>
              <option value="dota">Dota 2</option>
              <option value="cs2">CS2</option>
            </select>
          </div>
          <div style={{ gridColumn: "1 / -1" }}>
            <label style={label}>Ссылка на аватар</label>
            <input style={field} value={form.avatar_url} onChange={upd("avatar_url")} placeholder="https://…" />
          </div>
          <div style={{ gridColumn: "1 / -1" }}>
            <label style={label}>О себе</label>
            <textarea style={{ ...field, minHeight: 76, resize: "vertical" }} value={form.bio} onChange={upd("bio")} placeholder="Пара слов о себе" />
          </div>
        </div>
      </Panel>

      <Panel>
        <SectionTitle title="Привязка Dota 2" sub="Account ID будет использоваться по умолчанию в дашборде" />
        <label style={label}>Dota Account ID</label>
        <div className="flex gap-2 flex-wrap">
          <input style={{ ...field, maxWidth: 280 }} value={form.dota_account_id} onChange={upd("dota_account_id")} placeholder="например 369102305" inputMode="numeric" />
          <button onClick={useLastSearched}
            style={{ display: "inline-flex", alignItems: "center", gap: 7, background: C.surf, border: "1px solid " + C.border, color: C.text, borderRadius: 9, padding: "10px 13px", cursor: "pointer", fontFamily: "Manrope, sans-serif", fontSize: 13 }}>
            <Link2 size={14} color={C.green} /> Взять из последнего поиска
          </button>
        </div>
      </Panel>

      <div className="flex items-center gap-3">
        <button onClick={save} disabled={busy}
          style={{ display: "inline-flex", alignItems: "center", gap: 8, background: C.green, border: "none", color: C.bg, borderRadius: 10, padding: "11px 20px", cursor: busy ? "default" : "pointer", fontFamily: "Manrope, sans-serif", fontSize: 14, fontWeight: 800, opacity: busy ? 0.7 : 1 }}>
          {busy ? <Loader2 size={15} className="animate-spin" /> : saved ? <Check size={15} /> : null}
          {saved ? "Сохранено" : "Сохранить изменения"}
        </button>
        {err ? <span style={{ color: C.red, fontSize: 12.5 }}>{err}</span> : null}
      </div>
    </div>
  );
}
