import { useState } from "react";
import { useNavigate } from "react-router";
import { Sparkles, Loader2, Target, AlertTriangle, Star, Dumbbell, ShieldOff, ArrowRight, Search } from "lucide-react";
import { Panel, SectionTitle, Pill, C } from "./_kit";
import { usePlayer } from "../../lib/store";
import { aiCoach } from "../../lib/api";
import { heroName } from "../../lib/heroes";

type Q = { key: string; title: string; options: string[] };

const SURVEY: Q[] = [
  { key: "goal", title: "Какая у тебя главная цель?", options: ["Поднять MMR", "Стабильные результаты", "Освоить новую роль", "Разобрать слабые места", "Готовлюсь к турниру"] },
  { key: "role", title: "Какую позицию играешь чаще всего?", options: ["Carry (1)", "Mid (2)", "Offlane (3)", "Support (4)", "Hard support (5)"] },
  { key: "concern", title: "Что беспокоит больше всего?", options: ["Фарм и экономика", "Слишком много смертей", "Тимфайты", "Драфт и пики", "Вижн и контроль карты", "Тайминги и темп"] },
  { key: "time", title: "Сколько времени готов уделять?", options: ["30 минут в день", "1 час в день", "Несколько игр в неделю", "Минимум, только ключевое"] },
];

const SECTIONS: { key: string; title: string; icon: any; color: string; hero?: boolean }[] = [
  { key: "main_mistakes", title: "Главные ошибки", icon: AlertTriangle, color: C.red },
  { key: "recommendations", title: "Рекомендации", icon: Star, color: C.gold },
  { key: "training_plan", title: "План тренировок", icon: Dumbbell, color: C.green },
  { key: "heroes_to_focus", title: "Герои в фокус", icon: Star, color: C.green, hero: true },
  { key: "heroes_to_avoid", title: "Кого ограничить", icon: ShieldOff, color: C.red, hero: true },
  { key: "next_steps", title: "Следующие шаги", icon: ArrowRight, color: C.blue },
];

function itemText(hero: boolean | undefined, raw: string) {
  const n = Number(raw);
  if (hero && Number.isInteger(n) && n > 0 && n < 200) return heroName(n);
  return raw;
}

export default function Coach() {
  const { accountId } = usePlayer();
  let stored = "";
  try { stored = localStorage.getItem("gm.dotaId") || ""; } catch { /* ignore */ }
  const acc = accountId || stored;
  const nav = useNavigate();
  const [answers, setAnswers] = useState<Record<string, string>>({});
  const [customOpen, setCustomOpen] = useState<Record<string, boolean>>({});
  const [report, setReport] = useState<any>(null);
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState("");

  const pick = (k: string, v: string) => { setAnswers((a) => ({ ...a, [k]: v })); setCustomOpen((c) => ({ ...c, [k]: false })); };

  const buildFocus = () => {
    const parts: string[] = [];
    SURVEY.forEach((q) => { if (answers[q.key]) parts.push(q.title + " — " + answers[q.key]); });
    return parts.join("\n");
  };

  const run = async () => {
    if (!acc) return;
    setLoading(true); setErr(""); setReport(null);
    try {
      setReport(await aiCoach.review(acc, buildFocus()));
    } catch (e: any) {
      setErr(/disabled|provider/i.test(e?.message || "") ? "AI выключен на сервере (нет ключа модели)." : (e?.message || "Не удалось получить план"));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex flex-col gap-4">
      <Panel style={{ borderColor: C.gold + "33" }}>
        <SectionTitle
          title={<span className="inline-flex items-center gap-2"><Sparkles size={16} color={C.gold} /> AI-коуч: персональный план</span>}
          sub="Ответь на пару вопросов — ИИ составит план именно под твою цель"
          right={<Pill color={C.gold}>AI</Pill>}
        />
        {!accountId ? (
          <div className="flex items-center gap-2" style={{ color: C.muted, fontSize: 13.5 }}>
            <Search size={15} /> Сначала найди игрока через поиск (или укажи Dota ID в профиле).
          </div>
        ) : (
          <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 12.5, color: C.muted }}>Разбор строится по твоим реальным матчам, перцентилям и IMP.</div>
        )}
      </Panel>

      {/* Survey */}
      <div className="grid gap-4" style={{ gridTemplateColumns: "repeat(auto-fit, minmax(320px, 1fr))" }}>
        {SURVEY.map((q) => (
          <Panel key={q.key}>
            <div style={{ fontFamily: "Manrope, sans-serif", fontWeight: 700, fontSize: 14, color: C.text, marginBottom: 10 }}>{q.title}</div>
            <div className="flex flex-wrap gap-2">
              {q.options.map((opt) => {
                const active = answers[q.key] === opt;
                return (
                  <button key={opt} onClick={() => pick(q.key, opt)}
                    style={{ fontFamily: "Manrope, sans-serif", fontSize: 12.5, fontWeight: 600, padding: "8px 13px", borderRadius: 999, cursor: "pointer",
                      background: active ? C.green : C.surf, color: active ? C.bg : C.text, border: "1px solid " + (active ? C.green : C.border) }}>
                    {opt}
                  </button>
                );
              })}
              <button onClick={() => setCustomOpen((c) => ({ ...c, [q.key]: !c[q.key] }))}
                style={{ fontFamily: "Manrope, sans-serif", fontSize: 12.5, fontWeight: 600, padding: "8px 13px", borderRadius: 999, cursor: "pointer", background: "transparent", color: C.muted, border: "1px dashed " + C.border }}>
                + свой
              </button>
            </div>
            {customOpen[q.key] ? (
              <input autoFocus value={answers[q.key] && !q.options.includes(answers[q.key]) ? answers[q.key] : ""}
                onChange={(e) => setAnswers((a) => ({ ...a, [q.key]: e.target.value }))}
                placeholder="Свой вариант…"
                style={{ marginTop: 10, width: "100%", background: C.bg, border: "1px solid " + C.border, borderRadius: 9, padding: "9px 12px", color: C.text, fontFamily: "Manrope, sans-serif", fontSize: 13, outline: "none" }} />
            ) : null}
          </Panel>
        ))}
      </div>

      <div className="flex items-center gap-3 flex-wrap">
        <button onClick={run} disabled={!accountId || loading}
          style={{ display: "inline-flex", alignItems: "center", gap: 8, background: accountId ? C.gold : C.surf, color: accountId ? C.bg : C.muted, border: "none", borderRadius: 12, padding: "13px 24px", cursor: accountId && !loading ? "pointer" : "not-allowed", fontFamily: "Manrope, sans-serif", fontWeight: 800, fontSize: 14 }}>
          {loading ? <Loader2 size={16} className="animate-spin" /> : <Sparkles size={16} />}
          {loading ? "ИИ составляет план…" : "Получить план от ИИ"}
        </button>
        {err ? <span style={{ color: C.red, fontSize: 12.5 }}>{err}</span> : null}
      </div>

      {/* Result */}
      {report ? (
        <>
          {report.summary ? (
            <Panel style={{ borderColor: C.gold + "33" }}>
              <SectionTitle title="Вывод ИИ" sub="Кратко о твоём профиле" />
              <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 14, color: C.text, lineHeight: 1.6 }}>{report.summary}</div>
            </Panel>
          ) : null}
          <div className="grid gap-4" style={{ gridTemplateColumns: "repeat(auto-fit, minmax(300px, 1fr))" }}>
            {SECTIONS.map((s) => {
              const items: string[] = report[s.key] || [];
              if (!items.length) return null;
              const Icon = s.icon;
              return (
                <Panel key={s.key}>
                  <div className="flex items-center gap-2 mb-3">
                    <Icon size={15} color={s.color} />
                    <span style={{ fontFamily: "Manrope, sans-serif", fontWeight: 700, fontSize: 14, color: C.text }}>{s.title}</span>
                  </div>
                  <div className="flex flex-col gap-2.5">
                    {items.map((t, i) => (
                      <div key={i} className="flex items-start gap-2.5">
                        <span style={{ width: 6, height: 6, borderRadius: 999, background: s.color, marginTop: 7, flexShrink: 0 }} />
                        <span style={{ fontFamily: "Manrope, sans-serif", fontSize: 13, color: C.text, lineHeight: 1.5 }}>{itemText(s.hero, t)}</span>
                      </div>
                    ))}
                  </div>
                </Panel>
              );
            })}
          </div>
        </>
      ) : null}
    </div>
  );
}
