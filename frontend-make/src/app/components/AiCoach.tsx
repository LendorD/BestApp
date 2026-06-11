import { useState, useEffect, useCallback } from "react";
import { Sparkles, ArrowRight, AlertTriangle, TrendingUp, Target, Loader2 } from "lucide-react";
import { usePlayer } from "../../lib/store";
import { aiCoach } from "../../lib/api";

const DEMO = [
  { icon: TrendingUp, color: "#00D084", bg: "rgba(0,208,132,0.08)", title: "Сильная сторона", body: "Высокий GPM относительно брекета — конвертируй фарм-преимущество в объекты быстрее." },
  { icon: AlertTriangle, color: "#F59E0B", bg: "rgba(245,158,11,0.08)", title: "Зона роста", body: "Многовато смертей в средней фазе — играй аккуратнее без выкупа." },
  { icon: Target, color: "#3B82F6", bg: "rgba(59,130,246,0.08)", title: "Фокус", body: "Сузь пул героев до сигнатурных — это поднимет винрейт." },
];

// Turn a CoachReport into up to 3 insight cards.
function toInsights(r: any) {
  const out: any[] = [];
  if (r?.strengths?.length) out.push({ icon: TrendingUp, color: "#00D084", bg: "rgba(0,208,132,0.08)", title: "Сильная сторона", body: r.strengths[0] });
  if (r?.weaknesses?.length) out.push({ icon: AlertTriangle, color: "#F59E0B", bg: "rgba(245,158,11,0.08)", title: "Слабая сторона", body: r.weaknesses[0] });
  const focus = (r?.recommendations && r.recommendations[0]) || (r?.next_steps && r.next_steps[0]) || (r?.main_mistakes && r.main_mistakes[0]);
  if (focus) out.push({ icon: Target, color: "#3B82F6", bg: "rgba(59,130,246,0.08)", title: "Что делать", body: focus });
  return out;
}

export function AiCoach() {
  const { accountId, live } = usePlayer();
  const [report, setReport] = useState<any>(null);
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState("");

  // Try cached latest report when a player loads.
  useEffect(() => {
    if (!accountId) { setReport(null); setErr(""); return; }
    let cancelled = false;
    aiCoach.latest(accountId).then((r: any) => { if (!cancelled) setReport(r); }).catch(() => {});
    return () => { cancelled = true; };
  }, [accountId]);

  const generate = useCallback(async () => {
    if (!accountId) return;
    setLoading(true); setErr("");
    try {
      setReport(await aiCoach.review(accountId));
    } catch (e: any) {
      if (e?.status === 401 || e?.code === "unauthorized") {
        setErr("Войдите в аккаунт, чтобы получить AI-разбор.");
      } else if (e?.code === "pro_required") {
        setErr("AI-разбор доступен по подписке Pro — оформи её в разделе «Подписка».");
      } else {
        setErr(e?.code === "provider_disabled" || /disabled|provider/i.test(e?.message || "")
          ? "AI выключен: задайте AI_API_KEY (OpenRouter) в .env бэкенда."
          : (e?.message || "Не удалось получить разбор"));
      }
    } finally {
      setLoading(false);
    }
  }, [accountId]);

  const insights = report ? toInsights(report) : DEMO;
  const isLive = !!report;

  return (
    <div className="rounded-lg p-5 relative overflow-hidden"
      style={{ background: "#0B0E13", border: "1px solid rgba(212,175,55,0.35)", boxShadow: "0 0 40px rgba(212,175,55,0.06)" }}>
      <div className="absolute top-0 right-0 w-48 h-48 pointer-events-none"
        style={{ background: "radial-gradient(circle, rgba(212,175,55,0.08) 0%, transparent 70%)" }} />

      <div className="flex items-center gap-2.5 mb-4 relative z-10">
        <div className="w-7 h-7 rounded-lg flex items-center justify-center"
          style={{ background: "rgba(212,175,55,0.15)", border: "1px solid rgba(212,175,55,0.25)" }}>
          <Sparkles size={14} color="#D4AF37" />
        </div>
        <div>
          <div style={{ fontFamily: "Manrope, sans-serif", fontWeight: 700, fontSize: 13, color: "#F4F6FA" }}>AI Coach</div>
          <div style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 9, color: "#D4AF37", letterSpacing: "0.06em" }}>
            {isLive ? "LIVE · РАЗБОР ПО ТВОИМ ДАННЫМ" : live ? "ГОТОВ К РАЗБОРУ" : "DEMO"}
          </div>
        </div>
        <div className="ml-auto px-2 py-0.5 rounded-full"
          style={{ background: "rgba(212,175,55,0.12)", border: "1px solid rgba(212,175,55,0.2)", fontFamily: "Manrope, sans-serif", fontWeight: 600, fontSize: 10, color: "#D4AF37" }}>
          {insights.length} insights
        </div>
      </div>

      {report?.summary ? (
        <div className="rounded-lg p-3 mb-3 relative z-10" style={{ background: "rgba(212,175,55,0.06)", border: "1px solid rgba(212,175,55,0.2)" }}>
          <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 12.5, color: "#F4F6FA", lineHeight: 1.55 }}>{report.summary}</div>
        </div>
      ) : null}

      <div className="flex flex-col gap-3 relative z-10">
        {insights.map(({ icon: Icon, color, bg, title, body }) => (
          <div key={title} className="flex gap-3 p-3 rounded-lg" style={{ background: bg, border: `1px solid ${color}20` }}>
            <div className="mt-0.5 shrink-0"><Icon size={14} color={color} /></div>
            <div>
              <div style={{ fontFamily: "Manrope, sans-serif", fontWeight: 600, fontSize: 12, color: "#F4F6FA", marginBottom: 2 }}>{title}</div>
              <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 11, color: "#8A94A6", lineHeight: 1.5 }}>{body}</div>
            </div>
          </div>
        ))}
      </div>

      {err ? <div className="mt-3 relative z-10" style={{ fontFamily: "Manrope, sans-serif", fontSize: 11.5, color: "#FF4560" }}>{err}</div> : null}

      <button onClick={generate} disabled={!accountId || loading}
        className="mt-4 w-full flex items-center justify-center gap-2 py-2 rounded-lg relative z-10 transition-all"
        style={{
          background: accountId ? "rgba(212,175,55,0.12)" : "rgba(138,148,166,0.08)",
          border: "1px solid rgba(212,175,55,0.25)", fontFamily: "Manrope, sans-serif", fontWeight: 600, fontSize: 12,
          color: accountId ? "#D4AF37" : "#8A94A6", cursor: accountId && !loading ? "pointer" : "not-allowed",
        }}>
        {loading ? <Loader2 size={13} className="animate-spin" /> : <Sparkles size={13} />}
        {loading ? "ИИ анализирует…" : report ? "Обновить разбор" : accountId ? "Сгенерировать разбор" : "Найди игрока для разбора"}
        {!loading ? <ArrowRight size={13} /> : null}
      </button>
    </div>
  );
}
