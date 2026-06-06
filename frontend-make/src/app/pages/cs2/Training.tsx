import { C, Panel, SectionTitle, SellBlock, Pill, Meter } from "../_kit";
import { Dumbbell, Crosshair, Bomb, Brain, CheckCircle2 } from "lucide-react";

const O = "#FF6B00";
const DRILLS = [
  { icon: Crosshair, title: "Aim-дрилл", desc: "Aim Botz 15 мин + recoil master на AK/M4.", pct: 80, sub: "12 / 15 сессий" },
  { icon: Bomb, title: "Smoke-сеты", desc: "3 дефолт-смоука на текущей карте до автоматизма.", pct: 62, sub: "цель: 16 util dmg/раунд" },
  { icon: Brain, title: "Разбор демок", desc: "Найти un-traded смерти в 2 последних матчах.", pct: 48, sub: "2 демки/неделю" },
  { icon: Crosshair, title: "Prefire практика", desc: "Common angles на Mirage и Inferno.", pct: 35, sub: "prefire maps" },
];
const PLAN = [
  ["ПН", "Aim + recoil", "15 мин Aim Botz, 50 спреев AK"],
  ["ВТ", "Smoke lineups", "3 смоука на Mirage из мьюзкл-мемори"],
  ["СР", "DM + prefire", "2 дезматча, prefire common angles"],
  ["ЧТ", "Premier", "3 матча, фокус на трейд перед энтри"],
  ["ПТ", "Разбор демок", "Найти ошибки позиционирования"],
  ["СБ", "Clutch практика", "1vX ретейки на ретейк-картах"],
];

export default function Training() {
  return (
    <>
      <SellBlock
        kicker="CS2 · TRAINING"
        title="Не просто статистика — пошаговый план, который поднимает скилл"
        text="GameMentor собирает тренировку под твои слабые места: аим, утилити, позиционирование, клатчи. Каждый день — конкретное задание с измеримой целью и прогрессом."
        bullets={["Недельный план тренировок", "Дрилы под слабые места", "Измеримый прогресс", "Синхрон с разбором матчей"]}
        accent={O}
        cta="Составить мой план"
      />

      <SectionTitle title="Активные дрилы" sub="Прогресс этой недели" right={<Pill color={O}><Dumbbell size={11} /> 4 активных</Pill>} />
      <div className="grid gap-4" style={{ gridTemplateColumns: "repeat(auto-fit, minmax(240px, 1fr))" }}>
        {DRILLS.map((d) => (
          <Panel key={d.title}>
            <div className="flex items-center justify-between mb-2">
              <d.icon size={18} color={O} />
              <span style={{ fontFamily: "JetBrains Mono, monospace", fontWeight: 700, fontSize: 14, color: O }}>{d.pct}%</span>
            </div>
            <div style={{ fontFamily: "Manrope, sans-serif", fontWeight: 800, fontSize: 14, color: C.text }}>{d.title}</div>
            <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 12.5, color: C.muted, margin: "4px 0 10px", lineHeight: 1.45 }}>{d.desc}</div>
            <Meter value={d.pct} color={O} />
            <div style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 10.5, color: C.muted, marginTop: 8 }}>{d.sub}</div>
          </Panel>
        ))}
      </div>

      <Panel>
        <SectionTitle title="Расписание недели" sub="6 сессий · ~25 мин в день" right={<Pill color={O}>WEEK 1</Pill>} />
        <div className="flex flex-col gap-2">
          {PLAN.map(([day, title, desc]) => (
            <div key={day} className="flex items-center gap-3.5 rounded-lg p-3" style={{ background: C.bg, border: "1px solid " + C.border }}>
              <div className="w-10 h-10 rounded-lg flex items-center justify-center shrink-0" style={{ background: O + "14", border: "1px solid " + O + "3a", fontFamily: "JetBrains Mono, monospace", fontSize: 12, fontWeight: 800, color: O }}>{day}</div>
              <div className="flex-1 min-w-0">
                <div style={{ fontFamily: "Manrope, sans-serif", fontWeight: 800, fontSize: 13.5, color: C.text }}>{title}</div>
                <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 12, color: C.muted, marginTop: 2 }}>{desc}</div>
              </div>
              <CheckCircle2 size={18} color={C.muted} />
            </div>
          ))}
        </div>
      </Panel>
    </>
  );
}
