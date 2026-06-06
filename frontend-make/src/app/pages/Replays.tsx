import { useState } from "react";
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, ReferenceLine } from "recharts";
import { C, Panel, SectionTitle, SellBlock, Pill } from "./_kit";
import { Sparkles, Search, CheckCircle2, AlertTriangle, Target, Loader2 } from "lucide-react";
import { usePlayer } from "../../lib/store";
import { aiCoach } from "../../lib/api";

const nw = [
  { t: "0", diff: 0 }, { t: "5", diff: 1200 }, { t: "10", diff: 3400 },
  { t: "15", diff: 2100 }, { t: "20", diff: 5600 }, { t: "25", diff: 4200 },
  { t: "30", diff: 8900 }, { t: "35", diff: 14200 }, { t: "38", diff: 19800 },
];
const moments = [
  { t: "02:40", kind: "good", text: "Идеальный размен на лайне — фарм-преимущество +900 голды." },
  { t: "11:20", kind: "bad", text: "Смерть без трейда на чужой стороне карты — потеря темпа." },
  { t: "18:05", kind: "good", text: "Своевременный BKB в файте, выжил и закрыл 2 фрага." },
  { t: "24:30", kind: "bad", text: "Преимущество не сконвертировано в Рошана/башню ~40 сек." },
  { t: "31:10", kind: "good", text: "Хайграунд на тайминг — взяли две башни и Аегис." },
];

export default function Replays() {
  const { accountId } = usePlayer();
  const [matchId, setMatchId] = useState("");
  const [busy, setBusy] = useState(false);
  const [report, setReport] = useState<any>(null);
  const [err, setErr] = useState("");

  const run = async () => {
    const id = matchId.trim();
    if (!id) return;
    setBusy(true); setErr(""); setReport(null);
    try {
      setReport(await aiCoach.reviewMatch(id, accountId || ""));
    } catch (e: any) {
      setErr(/disabled|provider/i.test(e?.message || "") || e?.code === "provider_disabled"
        ? "AI выключен: задайте AI_API_KEY (OpenRouter) в .env бэкенда."
        : (e?.message || "Не удалось разобрать матч"));
    } finally {
      setBusy(false);
    }
  };

  return (
    <>
      <SellBlock
        kicker="REPLAY AI"
        title="Полный разбор реплея — как от личного тренера, но за секунды"
        text="Вставь ID матча — GameMentor распарсит реплей и ИИ разложит игру по полочкам: ключевые моменты с таймкодами, ошибки и их причины, упущенные тайминги, конкретные рекомендации и план тренировки под этот матч."
        bullets={["Таймлайн ключевых моментов", "Разбор ошибок и причин", "График преимущества по голде", "Готовый план тренировки"]}
        cta="Разобрать матч"
      />

      <Panel>
        <SectionTitle title="Анализ реплея" sub="ID матча из Dota 2 / OpenDota" />
        <div className="flex gap-2.5 flex-wrap">
          <div className="flex items-center gap-2 rounded-lg px-3.5 flex-1" style={{ background: C.surf, border: "1px solid " + C.border, minWidth: 220, maxWidth: 360 }}>
            <Search size={15} color={C.muted} />
            <input value={matchId} onChange={(e) => setMatchId(e.target.value)} placeholder="напр. 7891234567"
              style={{ background: "transparent", border: "none", outline: "none", padding: "11px 0", width: "100%", fontFamily: "JetBrains Mono, monospace", fontSize: 13, color: C.text }} />
          </div>
          <button onClick={run} disabled={busy || !matchId.trim()}
            style={{ fontFamily: "Manrope, sans-serif", fontWeight: 700, fontSize: 13, color: C.bg, background: busy || !matchId.trim() ? C.surf : C.green, border: "none", borderRadius: 8, padding: "0 22px", cursor: busy ? "not-allowed" : "pointer", display: "flex", alignItems: "center", gap: 8 }}>
            {busy ? <Loader2 size={15} className="animate-spin" /> : <Sparkles size={15} color={C.bg} />} {busy ? "ИИ разбирает…" : "Разобрать"}
          </button>
        </div>
        {err ? <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 12.5, color: C.red, marginTop: 10 }}>{err}</div>
          : <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 12, color: C.muted, marginTop: 10 }}>
              {report ? "Разбор матча " + matchId + " от ИИ ниже." : "Вставь ID матча и нажми «Разобрать». Если реплей ещё не распарсен — повтори через ~минуту."}
            </div>}
      </Panel>

      <Panel>
        <SectionTitle title="Преимущество по голде" sub="Разница нетворса с командой соперника" right={<Pill color={C.gold}>◆ AI</Pill>} />
        <ResponsiveContainer width="100%" height={220}>
          <AreaChart data={nw} margin={{ top: 4, right: 8, left: -10, bottom: 0 }}>
            <defs><linearGradient id="nw" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stopColor={C.green} stopOpacity={0.3} /><stop offset="100%" stopColor={C.green} stopOpacity={0} /></linearGradient></defs>
            <CartesianGrid stroke={C.border} strokeDasharray="3 3" vertical={false} />
            <XAxis dataKey="t" tick={{ fontFamily: "JetBrains Mono, monospace", fontSize: 10, fill: C.muted }} axisLine={false} tickLine={false} unit="m" />
            <YAxis tick={{ fontFamily: "JetBrains Mono, monospace", fontSize: 10, fill: C.muted }} axisLine={false} tickLine={false} />
            <ReferenceLine y={0} stroke={C.border} />
            <Tooltip contentStyle={{ background: C.surf, border: "1px solid " + C.border, borderRadius: 6, fontFamily: "JetBrains Mono, monospace", fontSize: 11 }} />
            <Area type="monotone" dataKey="diff" stroke={C.green} fill="url(#nw)" strokeWidth={2} />
          </AreaChart>
        </ResponsiveContainer>
      </Panel>

      <div className="grid gap-4 grid-cols-1 lg:grid-cols-[1.2fr_1fr]">
        <Panel>
          <SectionTitle title={report ? "Главные ошибки" : "Ключевые моменты"} sub={report ? "По разбору ИИ" : "С таймкодами (пример)"} />
          <div className="flex flex-col gap-2.5">
            {report ? (
              (report.main_mistakes?.length ? report.main_mistakes : report.weaknesses || []).map((t: string, i: number) => (
                <div key={i} className="flex items-start gap-3 rounded-lg p-3" style={{ background: C.bg, border: "1px solid " + C.border, borderLeft: "3px solid " + C.red }}>
                  <AlertTriangle size={16} color={C.red} style={{ flexShrink: 0, marginTop: 1 }} />
                  <span style={{ fontFamily: "Manrope, sans-serif", fontSize: 13, color: C.text, lineHeight: 1.45 }}>{t}</span>
                </div>
              ))
            ) : (
              moments.map((m) => (
                <div key={m.t} className="flex items-start gap-3 rounded-lg p-3" style={{ background: C.bg, border: "1px solid " + C.border, borderLeft: "3px solid " + (m.kind === "good" ? C.green : C.red) }}>
                  <span style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 12, fontWeight: 700, color: m.kind === "good" ? C.green : C.red, minWidth: 44 }}>{m.t}</span>
                  {m.kind === "good" ? <CheckCircle2 size={16} color={C.green} /> : <AlertTriangle size={16} color={C.red} />}
                  <span style={{ fontFamily: "Manrope, sans-serif", fontSize: 13, color: C.text, lineHeight: 1.45 }}>{m.text}</span>
                </div>
              ))
            )}
          </div>
        </Panel>

        <Panel style={{ borderColor: C.gold + "33" }}>
          <SectionTitle title={<span className="inline-flex items-center gap-2"><Sparkles size={15} color={C.gold} /> Вердикт AI</span>} sub="Итог по матчу" />
          <div className="rounded-lg p-3 mb-3" style={{ background: C.bg, border: "1px solid " + C.border }}>
            <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 13, color: C.text, lineHeight: 1.55 }}>
              {report?.summary || "Сильная игра по фарму, но дважды упустил конвертацию преимущества в объекты на 24-26 мин. Это стоило ~6 минут темпа."}
            </div>
          </div>
          {(report
            ? [
                ["Рекомендация", report.recommendations?.[0], C.gold],
                ["Тренировка", report.training_plan?.[0], C.green],
                ["Следующий шаг", report.next_steps?.[0], C.blue],
              ].filter((x) => x[1])
            : [["Главная ошибка", "Не давишь после выигранных файтов", C.red], ["Рекомендация", "После файта — Рошан/башня в течение 25 сек", C.gold], ["Тренировка", "3 игры с фокусом на пуш-тайминги", C.green]]
          ).map(([t, d, col]) => (
            <div key={t as string} className="flex items-start gap-2.5 mb-2.5">
              <Target size={14} color={col as string} style={{ marginTop: 2 }} />
              <div><div style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 9.5, color: col as string, letterSpacing: "0.06em" }}>{(t as string).toUpperCase()}</div>
                <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 12.5, color: C.text, lineHeight: 1.45 }}>{d as string}</div></div>
            </div>
          ))}
        </Panel>
      </div>
    </>
  );
}
