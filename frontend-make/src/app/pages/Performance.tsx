import {
  LineChart, Line, AreaChart, Area, BarChart, Bar, XAxis, YAxis,
  CartesianGrid, Tooltip, ResponsiveContainer, RadialBarChart, RadialBar,
} from "recharts";
import { C, Panel, SectionTitle, SellBlock, Pill } from "./_kit";
import { TrendingUp, Clock, Crosshair, Activity } from "lucide-react";
import { usePlayer } from "../../lib/store";

const wr = [
  { d: "W1", winrate: 54, kda: 3.6 }, { d: "W2", winrate: 58, kda: 3.9 },
  { d: "W3", winrate: 52, kda: 3.4 }, { d: "W4", winrate: 61, kda: 4.3 },
  { d: "W5", winrate: 63, kda: 4.5 }, { d: "W6", winrate: 60, kda: 4.2 },
  { d: "W7", winrate: 66, kda: 4.9 }, { d: "W8", winrate: 64, kda: 4.7 },
];
const farm = [
  { d: "W1", gpm: 520, xpm: 560 }, { d: "W2", gpm: 548, xpm: 590 },
  { d: "W3", gpm: 535, xpm: 575 }, { d: "W4", gpm: 575, xpm: 612 },
  { d: "W5", gpm: 591, xpm: 638 }, { d: "W6", gpm: 583, xpm: 625 },
  { d: "W7", gpm: 612, xpm: 660 }, { d: "W8", gpm: 604, xpm: 651 },
];
const byDay = [
  { day: "Пн", wr: 61 }, { day: "Вт", wr: 55 }, { day: "Ср", wr: 64 },
  { day: "Чт", wr: 58 }, { day: "Пт", wr: 49 }, { day: "Сб", wr: 67 }, { day: "Вс", wr: 70 },
];
const roles = [
  { name: "Carry", value: 72, fill: C.green }, { name: "Mid", value: 61, fill: C.blue },
  { name: "Offlane", value: 54, fill: C.gold }, { name: "Support", value: 47, fill: C.purple },
];

function Tip({ active, payload, label }: any) {
  if (!active || !payload?.length) return null;
  return (
    <div style={{ background: C.surf, border: "1px solid " + C.border, borderRadius: 6, padding: "8px 12px", fontFamily: "JetBrains Mono, monospace", fontSize: 11 }}>
      <div style={{ color: C.muted, marginBottom: 4 }}>{label}</div>
      {payload.map((p: any) => <div key={p.name} style={{ color: p.color }}>{p.name}: {p.value}</div>)}
    </div>
  );
}

function MiniStat({ icon: Icon, label, value, sub, color }: any) {
  return (
    <Panel>
      <div className="flex items-center justify-between">
        <Icon size={18} color={color} />
        <TrendingUp size={14} color={C.green} />
      </div>
      <div style={{ fontFamily: "JetBrains Mono, monospace", fontWeight: 700, fontSize: 24, color: C.text, margin: "10px 0 2px" }}>{value}</div>
      <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 12, color: C.text }}>{label}</div>
      <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 11, color: C.muted }}>{sub}</div>
    </Panel>
  );
}

function kpi(data: any, match: string) {
  const k = (data?.kpis || []).find((x: any) => (x.label || "").toLowerCase().includes(match));
  return k ? { value: k.value, sub: k.sub || "" } : null;
}

export default function Performance() {
  const { data, live } = usePlayer();

  const trendData = data?.trend?.length
    ? data.trend.map((t: any) => ({ d: String(t.date).slice(5), winrate: t.winrate, kda: t.kda }))
    : wr;

  const mWr = kpi(data, "винрейт") || kpi(data, "winrate");
  const mKda = kpi(data, "kda");
  const mGpm = kpi(data, "gpm");

  return (
    <>
      <SellBlock
        kicker="PERFORMANCE LAB"
        title="Видишь не цифры, а тренды — и понимаешь, что тянет рейтинг вниз"
        text="Полная картина твоей формы: винрейт и KDA по неделям, темп фарма, лучшие дни и роли. GameMentor находит закономерности, которые невозможно заметить вручную, и подсказывает, где именно ты теряешь MMR."
        bullets={["Тренды за 8 недель", "Разбивка по ролям и дням", "Темп фарма GPM/XPM", "Готово к экспорту в AI Coach"]}
        cta="Получить разбор формы"
      />

      <div className="grid gap-3" style={{ gridTemplateColumns: "repeat(auto-fit, minmax(180px, 1fr))" }}>
        <MiniStat icon={Activity} label="Винрейт" value={mWr ? mWr.value : "63%"} sub={mWr ? mWr.sub : "48 игр"} color={C.green} />
        <MiniStat icon={Crosshair} label="KDA" value={mKda ? mKda.value : "4.2"} sub={mKda ? mKda.sub : "+0.4 к прошлому"} color={C.blue} />
        <MiniStat icon={TrendingUp} label="GPM" value={mGpm ? mGpm.value : "591"} sub={mGpm ? mGpm.sub : "топ 8% брекета"} color={C.gold} />
        <MiniStat icon={Clock} label="Источник" value={live ? "LIVE" : "DEMO"} sub={live ? "OpenDota" : "пример"} color={C.purple} />
      </div>

      <Panel>
        <SectionTitle title="Тренд формы" sub={live ? "Винрейт и KDA по последним матчам" : "Винрейт и KDA (пример)"} right={<Pill>{live ? "live" : "демо"}</Pill>} />
        <ResponsiveContainer width="100%" height={240}>
          <LineChart data={trendData} margin={{ top: 4, right: 8, left: -20, bottom: 0 }}>
            <CartesianGrid stroke={C.border} strokeDasharray="3 3" vertical={false} />
            <XAxis dataKey="d" tick={{ fontFamily: "JetBrains Mono, monospace", fontSize: 10, fill: C.muted }} axisLine={false} tickLine={false} />
            <YAxis tick={{ fontFamily: "JetBrains Mono, monospace", fontSize: 10, fill: C.muted }} axisLine={false} tickLine={false} />
            <Tooltip content={<Tip />} />
            <Line type="monotone" dataKey="winrate" stroke={C.green} strokeWidth={2} dot={false} />
            <Line type="monotone" dataKey="kda" stroke={C.blue} strokeWidth={2} dot={false} />
          </LineChart>
        </ResponsiveContainer>
      </Panel>

      <div className="grid gap-4 grid-cols-1 lg:grid-cols-2">
        <Panel>
          <SectionTitle title="Темп фарма" sub="GPM / XPM по неделям" />
          <ResponsiveContainer width="100%" height={220}>
            <AreaChart data={farm} margin={{ top: 4, right: 8, left: -20, bottom: 0 }}>
              <defs>
                <linearGradient id="g1" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stopColor={C.green} stopOpacity={0.3} /><stop offset="100%" stopColor={C.green} stopOpacity={0} /></linearGradient>
                <linearGradient id="g2" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stopColor={C.blue} stopOpacity={0.25} /><stop offset="100%" stopColor={C.blue} stopOpacity={0} /></linearGradient>
              </defs>
              <CartesianGrid stroke={C.border} strokeDasharray="3 3" vertical={false} />
              <XAxis dataKey="d" tick={{ fontFamily: "JetBrains Mono, monospace", fontSize: 10, fill: C.muted }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fontFamily: "JetBrains Mono, monospace", fontSize: 10, fill: C.muted }} axisLine={false} tickLine={false} />
              <Tooltip content={<Tip />} />
              <Area type="monotone" dataKey="gpm" stroke={C.green} fill="url(#g1)" strokeWidth={2} />
              <Area type="monotone" dataKey="xpm" stroke={C.blue} fill="url(#g2)" strokeWidth={2} />
            </AreaChart>
          </ResponsiveContainer>
        </Panel>

        <Panel>
          <SectionTitle title="Винрейт по дням недели" sub="Когда ты играешь лучше всего" />
          <ResponsiveContainer width="100%" height={220}>
            <BarChart data={byDay} margin={{ top: 4, right: 8, left: -20, bottom: 0 }}>
              <CartesianGrid stroke={C.border} strokeDasharray="3 3" vertical={false} />
              <XAxis dataKey="day" tick={{ fontFamily: "JetBrains Mono, monospace", fontSize: 10, fill: C.muted }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fontFamily: "JetBrains Mono, monospace", fontSize: 10, fill: C.muted }} axisLine={false} tickLine={false} />
              <Tooltip content={<Tip />} />
              <Bar dataKey="wr" radius={[4, 4, 0, 0]} fill={C.green} />
            </BarChart>
          </ResponsiveContainer>
        </Panel>
      </div>

      <div className="grid gap-4 grid-cols-1 lg:grid-cols-2">
        <Panel>
          <SectionTitle title="Винрейт по ролям" sub="На какой позиции ты сильнее" />
          <ResponsiveContainer width="100%" height={220}>
            <RadialBarChart innerRadius="30%" outerRadius="100%" data={roles} startAngle={90} endAngle={-270}>
              <RadialBar dataKey="value" cornerRadius={6} background={{ fill: C.surf }} />
              <Tooltip content={<Tip />} />
            </RadialBarChart>
          </ResponsiveContainer>
          <div className="flex flex-wrap gap-3 mt-2 justify-center">
            {roles.map((r) => (
              <span key={r.name} className="flex items-center gap-1.5" style={{ fontFamily: "Manrope, sans-serif", fontSize: 12, color: C.muted }}>
                <span style={{ width: 9, height: 9, borderRadius: 3, background: r.fill }} />{r.name} {r.value}%
              </span>
            ))}
          </div>
        </Panel>

        <Panel>
          <SectionTitle title="Что говорит AI" sub="Авто-инсайты по твоей форме" right={<Pill color={C.gold}>◆ AI</Pill>} />
          <div className="flex flex-col gap-3">
            {[
              ["Пик формы — выходные", "Винрейт в Сб-Вс на 12% выше будней. Планируй ранкед на выходные.", C.green],
              ["Просадка в пятницу", "49% винрейт по пятницам — самый слабый день. Меньше игр после работы.", C.red],
              ["Фарм растёт", "GPM вырос с 520 до 612 за 8 недель. Конвертируй фарм в объекты быстрее.", C.gold],
            ].map(([t, d, col]) => (
              <div key={t as string} className="rounded-lg p-3" style={{ background: C.bg, border: "1px solid " + C.border, borderLeft: "3px solid " + col }}>
                <div style={{ fontFamily: "Manrope, sans-serif", fontWeight: 700, fontSize: 13, color: C.text }}>{t}</div>
                <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 12.5, color: C.muted, marginTop: 4, lineHeight: 1.5 }}>{d}</div>
              </div>
            ))}
          </div>
        </Panel>
      </div>
    </>
  );
}
