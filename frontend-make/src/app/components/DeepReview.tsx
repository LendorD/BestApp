import { useEffect, useState, useCallback } from "react";
import { useNavigate } from "react-router";
import { Lock, Sparkles, Crown, AlertTriangle, Dumbbell, Star, ShieldOff, ArrowRight, Loader2 } from "lucide-react";
import { usePlayer } from "../../lib/store";
import { useAuth } from "../../lib/auth";
import { aiCoach } from "../../lib/api";
import { heroName } from "../../lib/heroes";

const C = { bg: "#050608", card: "#0B0E13", surf: "#10141B", border: "#1B2430", text: "#F4F6FA", muted: "#8A94A6", green: "#00D084", gold: "#D4AF37", red: "#FF4560", blue: "#3B82F6" };

const SECTION_META: Record<string, { icon: any; color: string; title: string }> = {
  main_mistakes: { icon: AlertTriangle, color: C.red, title: "Главные ошибки" },
  recommendations: { icon: Star, color: C.gold, title: "Рекомендации" },
  training_plan: { icon: Dumbbell, color: C.green, title: "План тренировок" },
  heroes_to_focus: { icon: Star, color: C.green, title: "Герои в фокус" },
  heroes_to_avoid: { icon: ShieldOff, color: C.red, title: "Кого ограничить" },
  next_steps: { icon: ArrowRight, color: C.blue, title: "Следующие шаги" },
};
const ORDER = ["main_mistakes", "recommendations", "training_plan", "heroes_to_focus", "heroes_to_avoid", "next_steps"];

// Plausible-looking placeholder so the locked state still reads like real value.
const SAMPLE: Record<string, string[]> = {
  main_mistakes: ["Слишком пассивный фарм в ранней игре", "Поздние варды в мид-фазе", "Не конвертируешь файты в объекты"],
  recommendations: ["Раньше выходить на ключевой тайминг", "Стабильнее закрывать крипов на линии", "После выигранного файта — Рошан/башня"],
  training_plan: ["3 игры с фокусом на ластхиты", "Тренировка таймингов предметов", "Разбор 5 поражений на повторе"],
  heroes_to_focus: ["Твои сигнатурные керри", "Герои под текущую мету", "Пики с высоким импактом"],
  heroes_to_avoid: ["Минусовой винрейт", "Нестабильные пики", "Сложные тайминговые герои"],
  next_steps: ["Сузить пул до 8-10 героев", "Поднять CS/мин до брекет-нормы", "Снизить смерти в мид-фазе"],
};

function renderItem(key: string, raw: string) {
  // For hero sections the model sometimes returns hero ids; keep text as-is otherwise.
  const n = Number(raw);
  if ((key === "heroes_to_focus" || key === "heroes_to_avoid") && Number.isInteger(n) && n > 0 && n < 200) {
    return heroName(n);
  }
  return raw;
}

function Block({ k, items }: { k: string; items: string[] }) {
  const m = SECTION_META[k];
  if (!m || !items?.length) return null;
  const Icon = m.icon;
  return (
    <div className="rounded-xl p-4" style={{ background: C.bg, border: "1px solid " + C.border }}>
      <div className="flex items-center gap-2 mb-2.5">
        <Icon size={14} color={m.color} />
        <span style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 10.5, letterSpacing: "0.06em", color: m.color }}>{m.title.toUpperCase()}</span>
      </div>
      <div className="flex flex-col gap-2">
        {items.slice(0, 4).map((t, i) => (
          <div key={i} className="flex items-start gap-2">
            <span style={{ width: 5, height: 5, borderRadius: 999, background: m.color, marginTop: 7, flexShrink: 0 }} />
            <span style={{ fontFamily: "Manrope, sans-serif", fontSize: 13, color: C.text, lineHeight: 1.5 }}>{renderItem(k, t)}</span>
          </div>
        ))}
      </div>
    </div>
  );
}

export function DeepReview() {
  const { accountId } = usePlayer();
  const { subscription, user } = useAuth();
  const nav = useNavigate();
  const [report, setReport] = useState<any>(null);
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState("");

  const pro = !!subscription && subscription.plan !== "free";

  useEffect(() => {
    if (!accountId) { setReport(null); return; }
    let cancelled = false;
    aiCoach.latest(accountId).then((r: any) => { if (!cancelled) setReport(r); }).catch(() => {});
    return () => { cancelled = true; };
  }, [accountId]);

  const generate = useCallback(async () => {
    if (!accountId) return;
    setLoading(true); setErr("");
    try { setReport(await aiCoach.review(accountId)); }
    catch (e: any) { setErr(/disabled|provider/i.test(e?.message || "") ? "AI выключен на сервере." : (e?.message || "Ошибка")); }
    finally { setLoading(false); }
  }, [accountId]);

  const data = report || SAMPLE;
  const locked = !pro;

  return (
    <div className="rounded-2xl relative overflow-hidden" style={{ background: C.card, border: "1px solid " + (locked ? C.gold + "44" : C.border) }}>
      <div className="absolute inset-0 pointer-events-none" style={{ background: "radial-gradient(120% 90% at 100% 0%, " + C.gold + "12, transparent 55%)" }} />

      {/* Header */}
      <div className="relative px-6 pt-6 pb-4 flex items-center gap-3 flex-wrap">
        <div className="w-9 h-9 rounded-xl flex items-center justify-center" style={{ background: "rgba(212,175,55,0.15)", border: "1px solid rgba(212,175,55,0.3)" }}>
          <Sparkles size={18} color={C.gold} />
        </div>
        <div className="flex-1 min-w-0">
          <div style={{ fontFamily: "Manrope, sans-serif", fontWeight: 800, fontSize: 18, color: C.text, letterSpacing: "-0.3px" }}>Глубокий разбор от ИИ</div>
          <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 12.5, color: C.muted }}>Полный план роста по твоим матчам, перцентилям и IMP</div>
        </div>
        {pro ? <span style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 10.5, color: C.gold, border: "1px solid " + C.gold + "44", borderRadius: 999, padding: "4px 10px" }}>PRO</span> : null}
      </div>

      {/* Body (blurred when locked) */}
      <div className="relative px-6 pb-6">
        <div style={locked ? { filter: "blur(7px)", pointerEvents: "none", userSelect: "none" } : undefined}>
          {report?.summary && !locked ? (
            <div className="rounded-xl p-4 mb-4" style={{ background: "rgba(212,175,55,0.06)", border: "1px solid rgba(212,175,55,0.2)" }}>
              <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 13.5, color: C.text, lineHeight: 1.6 }}>{report.summary}</div>
            </div>
          ) : null}
          <div className="grid gap-3" style={{ gridTemplateColumns: "repeat(auto-fit, minmax(260px, 1fr))" }}>
            {ORDER.map((k) => <Block key={k} k={k} items={data[k]} />)}
          </div>
        </div>

        {/* Lock overlay */}
        {locked ? (
          <div className="absolute inset-0 flex flex-col items-center justify-center text-center px-6"
            style={{ background: "linear-gradient(180deg, rgba(11,14,19,0.35), rgba(11,14,19,0.85))" }}>
            <div className="w-12 h-12 rounded-2xl flex items-center justify-center mb-3" style={{ background: "rgba(212,175,55,0.15)", border: "1px solid rgba(212,175,55,0.35)" }}>
              <Lock size={22} color={C.gold} />
            </div>
            <div style={{ fontFamily: "Manrope, sans-serif", fontWeight: 800, fontSize: 20, color: C.text, letterSpacing: "-0.3px" }}>Открой глубокий разбор</div>
            <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 13.5, color: C.muted, maxWidth: 460, marginTop: 8, lineHeight: 1.6 }}>
              Главные ошибки, персональный план тренировок, разбор героев и пошаговый план роста — всё на основе твоих реальных матчей. Доступно на тарифе Pro.
            </div>
            <button onClick={() => nav("/subscription")}
              className="mt-5 flex items-center gap-2"
              style={{ background: C.gold, color: C.bg, border: "none", borderRadius: 12, padding: "12px 24px", cursor: "pointer", fontFamily: "Manrope, sans-serif", fontWeight: 800, fontSize: 14 }}>
              <Crown size={16} /> Открыть в Pro <ArrowRight size={15} />
            </button>
            <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 11.5, color: C.muted, marginTop: 10 }}>Отменить можно в любой момент</div>
          </div>
        ) : null}
      </div>

      {/* Pro, but no report yet → generate */}
      {pro && !report ? (
        <div className="relative px-6 pb-6 -mt-2">
          <button onClick={generate} disabled={!accountId || loading}
            className="w-full flex items-center justify-center gap-2"
            style={{ background: "rgba(212,175,55,0.12)", border: "1px solid rgba(212,175,55,0.3)", color: C.gold, borderRadius: 12, padding: "12px 0", cursor: accountId && !loading ? "pointer" : "not-allowed", fontFamily: "Manrope, sans-serif", fontWeight: 700, fontSize: 14 }}>
            {loading ? <Loader2 size={15} className="animate-spin" /> : <Sparkles size={15} />}
            {loading ? "ИИ составляет разбор…" : accountId ? "Сгенерировать глубокий разбор" : "Найди игрока"}
          </button>
          {err ? <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 12, color: C.red, marginTop: 8, textAlign: "center" }}>{err}</div> : null}
        </div>
      ) : null}
    </div>
  );
}
