import { useState } from "react";
import { useNavigate, useLocation } from "react-router";
import { Loader2, Gamepad2, Mail, Lock, User as UserIcon } from "lucide-react";
import { useAuth } from "../../lib/auth";

const C = {
  bg: "#050608", card: "#0B0E13", surf: "#10141B", border: "#1B2430",
  text: "#F4F6FA", muted: "#8A94A6", accent: "#00D084", red: "#FF4560",
};

const field: React.CSSProperties = {
  background: C.surf, border: "1px solid " + C.border, borderRadius: 10,
  padding: "11px 12px 11px 38px", color: C.text, fontFamily: "Manrope, sans-serif",
  fontSize: 14, width: "100%", outline: "none",
};

export default function Auth() {
  const { login, register } = useAuth();
  const nav = useNavigate();
  const loc = useLocation() as any;
  const [mode, setMode] = useState<"login" | "register">(
    loc.pathname === "/register" ? "register" : "login"
  );
  const [form, setForm] = useState({ identity: "", email: "", username: "", password: "", display_name: "" });
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState("");

  const upd = (k: string) => (e: any) => setForm((f) => ({ ...f, [k]: e.target.value }));

  const submit = async () => {
    setErr(""); setBusy(true);
    try {
      if (mode === "login") {
        await login(form.identity.trim(), form.password);
      } else {
        await register({
          email: form.email.trim(),
          username: form.username.trim(),
          password: form.password,
          display_name: form.display_name.trim() || undefined,
        });
      }
      const to = loc.state?.from || "/";
      nav(to, { replace: true });
    } catch (e: any) {
      setErr(e?.message || "Что-то пошло не так");
    } finally {
      setBusy(false);
    }
  };

  return (
    <div style={{ minHeight: "100vh", width: "100%", display: "flex", alignItems: "center", justifyContent: "center", background: C.bg, fontFamily: "Manrope, sans-serif", padding: 20 }}>
      <div style={{ width: "100%", maxWidth: 400 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 10, justifyContent: "center", marginBottom: 22 }}>
          <div style={{ width: 38, height: 38, borderRadius: 10, background: "linear-gradient(135deg," + C.accent + ",#0AA968)", display: "flex", alignItems: "center", justifyContent: "center" }}>
            <Gamepad2 size={20} color="#04110B" />
          </div>
          <span style={{ fontSize: 20, fontWeight: 800, color: C.text }}>GameMentor</span>
        </div>

        <div style={{ background: C.card, border: "1px solid " + C.border, borderRadius: 16, padding: 24 }}>
          <div style={{ display: "flex", gap: 4, background: C.surf, borderRadius: 10, padding: 4, marginBottom: 20 }}>
            {(["login", "register"] as const).map((m) => (
              <button key={m} onClick={() => { setMode(m); setErr(""); }}
                style={{ flex: 1, padding: "8px 0", borderRadius: 7, border: "none", cursor: "pointer",
                  background: mode === m ? C.accent : "transparent", color: mode === m ? "#04110B" : C.muted,
                  fontFamily: "Manrope, sans-serif", fontSize: 13, fontWeight: 700 }}>
                {m === "login" ? "Вход" : "Регистрация"}
              </button>
            ))}
          </div>

          <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
            {mode === "login" ? (
              <Input icon={<UserIcon size={15} color={C.muted} />} placeholder="Email или имя пользователя" value={form.identity} onChange={upd("identity")} />
            ) : (
              <>
                <Input icon={<Mail size={15} color={C.muted} />} placeholder="Email" value={form.email} onChange={upd("email")} type="email" />
                <Input icon={<UserIcon size={15} color={C.muted} />} placeholder="Имя пользователя" value={form.username} onChange={upd("username")} />
                <Input icon={<UserIcon size={15} color={C.muted} />} placeholder="Отображаемое имя (необязательно)" value={form.display_name} onChange={upd("display_name")} />
              </>
            )}
            <Input icon={<Lock size={15} color={C.muted} />} placeholder="Пароль" value={form.password} onChange={upd("password")} type="password"
              onKeyDown={(e: any) => e.key === "Enter" && submit()} />

            {err ? <div style={{ color: C.red, fontSize: 12.5 }}>{err}</div> : null}

            <button onClick={submit} disabled={busy}
              style={{ marginTop: 4, padding: "11px 0", borderRadius: 10, border: "none", cursor: busy ? "default" : "pointer",
                background: C.accent, color: "#04110B", fontFamily: "Manrope, sans-serif", fontSize: 14, fontWeight: 800,
                display: "flex", alignItems: "center", justifyContent: "center", gap: 8, opacity: busy ? 0.7 : 1 }}>
              {busy ? <Loader2 size={16} className="animate-spin" /> : null}
              {mode === "login" ? "Войти" : "Создать аккаунт"}
            </button>
          </div>

          <p style={{ marginTop: 16, fontSize: 12, color: C.muted, textAlign: "center" }}>
            {mode === "login" ? "Нет аккаунта? " : "Уже есть аккаунт? "}
            <span onClick={() => { setMode(mode === "login" ? "register" : "login"); setErr(""); }}
              style={{ color: C.accent, cursor: "pointer", fontWeight: 700 }}>
              {mode === "login" ? "Зарегистрироваться" : "Войти"}
            </span>
          </p>
        </div>

        <p style={{ marginTop: 14, fontSize: 11.5, color: C.muted, textAlign: "center" }}>
          Войдите, чтобы сохранять профиль, привязать аккаунт Dota и оформить подписку.
        </p>
      </div>
    </div>
  );
}

function Input({ icon, ...props }: any) {
  return (
    <div style={{ position: "relative" }}>
      <span style={{ position: "absolute", left: 12, top: "50%", transform: "translateY(-50%)" }}>{icon}</span>
      <input {...props} style={field} />
    </div>
  );
}
