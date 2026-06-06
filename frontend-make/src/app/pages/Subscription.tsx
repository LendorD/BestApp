import { useEffect, useState } from "react";
import { useNavigate } from "react-router";
import { Loader2, Check, Crown, Sparkles } from "lucide-react";
import { Panel, SectionTitle, Pill, SellBlock, C } from "./_kit";
import { useAuth } from "../../lib/auth";
import { billing } from "../../lib/api";

interface Plan {
  id: string; name: string; price_monthly: number; currency: string;
  tagline: string; features: string[]; highlight?: boolean;
}

export default function Subscription() {
  const { user, subscription, ready, subscribe, cancelSubscription } = useAuth();
  const nav = useNavigate();
  const [plans, setPlans] = useState<Plan[]>([]);
  const [busy, setBusy] = useState("");
  const [err, setErr] = useState("");

  useEffect(() => {
    if (ready && !user) nav("/login", { replace: true, state: { from: "/subscription" } });
  }, [ready, user, nav]);

  useEffect(() => {
    billing.plans().then((d: any) => setPlans(d.plans || [])).catch(() => setPlans([]));
  }, []);

  const current = subscription?.plan || "free";

  const onSubscribe = async (id: string) => {
    setErr(""); setBusy(id);
    try { await subscribe(id); } catch (e: any) { setErr(e?.message || "Ошибка"); } finally { setBusy(""); }
  };
  const onCancel = async () => {
    setErr(""); setBusy("cancel");
    try { await cancelSubscription(); } catch (e: any) { setErr(e?.message || "Ошибка"); } finally { setBusy(""); }
  };

  return (
    <div className="flex flex-col gap-4">
      <SellBlock
        kicker="PRO"
        title="Прокачай свою игру с AI-коучем"
        text="Pro открывает разбор реплеев, персональные рекомендации и сравнение с про-игроками. Отменить можно в любой момент."
        bullets={["AI-разбор каждого матча", "Слабые стороны и план тренировок", "Сравнение с топ-игроками роли", "История без ограничений"]}
        accent={C.gold}
      />

      <Panel>
        <SectionTitle
          title="Текущий план"
          sub={subscription?.current_period_end ? "Активен до " + new Date(subscription.current_period_end).toLocaleDateString("ru-RU") : "Бесплатный тариф"}
          right={<Pill color={current === "free" ? C.muted : C.gold}><Crown size={11} /> {current.toUpperCase()}</Pill>}
        />
        {current !== "free" && (
          <button onClick={onCancel} disabled={busy === "cancel"}
            style={{ background: C.surf, border: "1px solid " + C.border, color: C.muted, borderRadius: 9, padding: "9px 15px", cursor: "pointer", fontFamily: "Manrope, sans-serif", fontSize: 13, display: "inline-flex", alignItems: "center", gap: 7 }}>
            {busy === "cancel" ? <Loader2 size={14} className="animate-spin" /> : null}
            Отменить подписку
          </button>
        )}
        {err ? <div style={{ color: C.red, fontSize: 12.5, marginTop: 10 }}>{err}</div> : null}
      </Panel>

      <div className="grid gap-4" style={{ gridTemplateColumns: "repeat(auto-fit, minmax(240px, 1fr))" }}>
        {plans.map((p) => {
          const isCurrent = p.id === current;
          const accent = p.highlight ? C.gold : C.green;
          return (
            <div key={p.id} style={{
              background: C.card, borderRadius: 14, padding: 22, position: "relative", overflow: "hidden",
              border: "1px solid " + (p.highlight ? C.gold + "55" : C.border),
            }}>
              {p.highlight && (
                <div style={{ position: "absolute", inset: 0, pointerEvents: "none", background: "radial-gradient(120% 120% at 100% 0%, " + C.gold + "16, transparent 55%)" }} />
              )}
              <div className="relative">
                <div className="flex items-center gap-2 mb-1">
                  <span style={{ fontSize: 16, fontWeight: 800, color: C.text }}>{p.name}</span>
                  {p.highlight ? <Sparkles size={14} color={C.gold} /> : null}
                </div>
                <div style={{ fontSize: 12.5, color: C.muted, marginBottom: 14, minHeight: 34 }}>{p.tagline}</div>
                <div style={{ marginBottom: 16 }}>
                  <span style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 30, fontWeight: 800, color: C.text }}>
                    {p.price_monthly === 0 ? "Free" : "$" + p.price_monthly}
                  </span>
                  {p.price_monthly > 0 && <span style={{ fontSize: 12.5, color: C.muted }}> /мес</span>}
                </div>
                <div className="flex flex-col gap-2 mb-5">
                  {p.features.map((f) => (
                    <div key={f} className="flex items-start gap-2">
                      <Check size={14} color={accent} style={{ marginTop: 2, flexShrink: 0 }} />
                      <span style={{ fontSize: 12.5, color: C.text }}>{f}</span>
                    </div>
                  ))}
                </div>
                {isCurrent ? (
                  <div style={{ textAlign: "center", padding: "10px 0", borderRadius: 9, border: "1px solid " + C.border, color: C.muted, fontFamily: "Manrope, sans-serif", fontSize: 13, fontWeight: 700 }}>
                    Текущий план
                  </div>
                ) : (
                  <button onClick={() => onSubscribe(p.id)} disabled={busy === p.id}
                    style={{ width: "100%", padding: "10px 0", borderRadius: 9, border: "none", cursor: "pointer",
                      background: accent, color: C.bg, fontFamily: "Manrope, sans-serif", fontSize: 13.5, fontWeight: 800,
                      display: "flex", alignItems: "center", justifyContent: "center", gap: 7, opacity: busy === p.id ? 0.7 : 1 }}>
                    {busy === p.id ? <Loader2 size={15} className="animate-spin" /> : null}
                    {p.price_monthly === 0 ? "Перейти на Free" : "Выбрать " + p.name}
                  </button>
                )}
              </div>
            </div>
          );
        })}
      </div>

      <p style={{ fontSize: 11.5, color: C.muted, textAlign: "center" }}>
        Демо-биллинг: оплата не списывается, план активируется сразу. Реальная оплата (Stripe) будет подключена позже.
      </p>
    </div>
  );
}
