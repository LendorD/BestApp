import { ReactNode } from "react";
import { useNavigate } from "react-router";
import { Crown, ArrowRight } from "lucide-react";
import { ProfileHeader } from "../components/ProfileHeader";
import { ScoreGauge } from "../components/ScoreGauge";
import { KpiCards } from "../components/KpiCards";
import { PerformanceTrend } from "../components/PerformanceTrend";
import { HexRadar } from "../components/HexRadar";
import { AiCoach } from "../components/AiCoach";
import { RecentMatches } from "../components/RecentMatches";
import { ProComparison } from "../components/ProComparison";
import { DeepReview } from "../components/DeepReview";
import { Reveal } from "../components/Reveal";

const C = { bg: "#050608", card: "#0B0E13", text: "#F4F6FA", muted: "#8A94A6", green: "#00D084", gold: "#D4AF37" };

// A "scene" in the scroll story: numbered kicker + title + content.
function Scene({ step, kicker, title, sub, children }: { step: string; kicker: string; title: string; sub?: string; children: ReactNode }) {
  return (
    <Reveal>
      <section className="flex flex-col gap-4">
        <div className="flex items-center gap-3">
          <span style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 12, fontWeight: 700, color: C.green, border: "1px solid " + C.green + "33", borderRadius: 8, padding: "3px 9px" }}>{step}</span>
          <div>
            <div style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 10.5, letterSpacing: "0.14em", color: C.muted }}>{kicker}</div>
            <div style={{ fontFamily: "Manrope, sans-serif", fontWeight: 800, fontSize: 22, color: C.text, letterSpacing: "-0.4px", lineHeight: 1.15 }}>{title}</div>
            {sub ? <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 13, color: C.muted, marginTop: 3 }}>{sub}</div> : null}
          </div>
        </div>
        {children}
      </section>
    </Reveal>
  );
}

export default function Overview() {
  const nav = useNavigate();

  return (
    <div className="flex flex-col" style={{ gap: 56 }}>
      {/* Scene 0 — identity */}
      <Reveal><ProfileHeader /></Reveal>

      {/* Scene 1 — your level */}
      <Scene step="01" kicker="ТВОЙ УРОВЕНЬ СЕЙЧАС" title="С чего ты стартуешь" sub="Общая оценка и ключевые показатели за выбранный период">
        <div className="grid gap-4 grid-cols-1 lg:grid-cols-[260px_minmax(0,1fr)]">
          <ScoreGauge />
          <div className="flex flex-col gap-4 min-w-0">
            <KpiCards />
            <PerformanceTrend />
          </div>
        </div>
      </Scene>

      {/* Scene 2 — skill profile */}
      <Scene step="02" kicker="ПРОФИЛЬ НАВЫКОВ" title="Где ты силён, а где проседаешь" sub="Радар сильных сторон и сравнение с топ-игроками роли">
        <div className="grid gap-4 grid-cols-1 lg:grid-cols-2">
          <HexRadar />
          <ProComparison />
        </div>
      </Scene>

      {/* Scene 3 — recent matches */}
      <Scene step="03" kicker="ПОСЛЕДНИЕ ИГРЫ" title="Что происходило в матчах" sub="Герои, результат и KDA последних игр">
        <RecentMatches />
      </Scene>

      {/* Scene 4 — free AI teaser */}
      <Scene step="04" kicker="БЕСПЛАТНЫЕ ИНСАЙТЫ ИИ" title="ИИ уже кое-что заметил" sub="Три наблюдения бесплатно — полный разбор ниже">
        <AiCoach />
      </Scene>

      {/* Scene 5 — paywalled deep review */}
      <Scene step="05" kicker="ГЛУБОКИЙ РАЗБОР" title="Полный план роста" sub="Главные ошибки, тренировки, разбор героев и пошаговый план">
        <DeepReview />
      </Scene>

      {/* Scene 6 — closing CTA */}
      <Reveal>
        <section className="rounded-2xl relative overflow-hidden" style={{ background: C.card, border: "1px solid " + C.gold + "33", padding: "40px 28px", textAlign: "center" }}>
          <div className="absolute inset-0 pointer-events-none" style={{ background: "radial-gradient(100% 120% at 50% 0%, " + C.gold + "14, transparent 60%)" }} />
          <div className="relative flex flex-col items-center">
            <span style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 11, letterSpacing: "0.14em", color: C.gold }}>GAMEMENTOR PRO</span>
            <div style={{ fontFamily: "Manrope, sans-serif", fontWeight: 800, fontSize: 28, color: C.text, letterSpacing: "-0.6px", margin: "10px 0", maxWidth: 560, lineHeight: 1.2 }}>
              Перестань гадать, почему стоишь на месте
            </div>
            <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 14.5, color: C.muted, maxWidth: 540, lineHeight: 1.6 }}>
              Pro открывает разбор каждого матча, персональный план тренировок и сравнение с про — всё на основе твоих реальных игр.
            </div>
            <button onClick={() => nav("/subscription")} className="mt-6 flex items-center gap-2"
              style={{ background: C.gold, color: C.bg, border: "none", borderRadius: 12, padding: "13px 26px", cursor: "pointer", fontFamily: "Manrope, sans-serif", fontWeight: 800, fontSize: 15 }}>
              <Crown size={17} /> Прокачать аккаунт <ArrowRight size={16} />
            </button>
          </div>
        </section>
      </Reveal>
    </div>
  );
}
