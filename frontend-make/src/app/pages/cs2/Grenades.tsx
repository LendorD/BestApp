import { useState } from "react";
import { C, Panel, SectionTitle, SellBlock, Pill } from "../_kit";
import { MapPin, Play } from "lucide-react";

const O = "#FF6B00";
const MAPS = ["Mirage", "Inferno", "Nuke", "Dust II", "Ancient", "Anubis", "Vertigo"];
const TYPES = [
  { type: "smoke", label: "Smoke", color: "#8A94A6" },
  { type: "flash", label: "Flash", color: "#F4F6FA" },
  { type: "molotov", label: "Molotov", color: O },
  { type: "he", label: "HE", color: "#FF4560" },
];
const GREN: Record<string, any[]> = {
  Mirage: [
    { type: "smoke", side: "T", name: "A Site Window", desc: "Убирает ротацию с Window при выходе на A." },
    { type: "smoke", side: "T", name: "CT Smoke", desc: "Закрывает выход CT на плент A." },
    { type: "flash", side: "T", name: "A Ramp Flash", desc: "Слепит игроков на рампе перед заходом." },
    { type: "molotov", side: "T", name: "Jungle Molotov", desc: "Выкуривает из-за ящиков на A." },
  ],
  Inferno: [
    { type: "smoke", side: "T", name: "Banana Smoke", desc: "Контроль банана при выходе с Т." },
    { type: "smoke", side: "CT", name: "B Defense", desc: "Дефолтный смоук на дефенс B." },
    { type: "molotov", side: "T", name: "Car Molotov", desc: "Поджигает позицию у машины." },
  ],
  Nuke: [{ type: "smoke", side: "T", name: "Heaven Smoke", desc: "Закрывает heaven при выходе outside." }],
  "Dust II": [{ type: "smoke", side: "T", name: "Long Doors", desc: "Помогает пройти Long без пика из A." }],
  Ancient: [{ type: "smoke", side: "T", name: "Mid-to-B Smoke", desc: "Сплит на B через мид." }],
  Anubis: [{ type: "flash", side: "T", name: "Connector Flash", desc: "Поп-флеш на коннектор." }],
  Vertigo: [{ type: "smoke", side: "T", name: "A Ramp Smoke", desc: "Закрывает рампу при пуше A." }],
};

export default function Grenades() {
  const [map, setMap] = useState("Mirage");
  const [type, setType] = useState<string | null>(null);
  const list = (GREN[map] || []).filter((g) => !type || g.type === type);
  return (
    <>
      <SellBlock
        kicker="CS2 · GRENADE LAB"
        title="База раскидок, по которой реально учат лайнапы"
        text="Готовые смоуки, флешки и молотовы для всех актуальных карт — с описанием, стороной и видео-инструкцией. Фильтруй по карте и типу, отрабатывай и закрывай раунды на дефолтах."
        bullets={["Все карты активного пула", "Smoke / Flash / Molotov / HE", "T и CT стороны", "Видео-лайнапы для каждой"]}
        accent={O}
        cta="Открыть тренировку раскидок"
      />

      <Panel style={{ borderColor: O + "33" }}>
        <div className="flex items-center gap-2 mb-4"><MapPin size={18} color={O} /><div style={{ fontFamily: "Manrope, sans-serif", fontWeight: 700, fontSize: 15, color: C.text }}>Карта и фильтры</div></div>
        <div className="flex flex-wrap gap-2 mb-3">
          {MAPS.map((m) => (
            <button key={m} onClick={() => setMap(m)} style={{ fontFamily: "Manrope, sans-serif", fontWeight: 700, fontSize: 12.5, padding: "7px 14px", borderRadius: 7, border: "none", cursor: "pointer", background: map === m ? O : C.surf, color: map === m ? C.bg : C.muted }}>{m}</button>
          ))}
        </div>
        <div className="flex flex-wrap gap-2">
          <button onClick={() => setType(null)} style={{ fontFamily: "Manrope, sans-serif", fontWeight: 700, fontSize: 12, padding: "6px 12px", borderRadius: 6, border: "none", cursor: "pointer", background: !type ? O : C.surf, color: !type ? C.bg : C.muted }}>Все</button>
          {TYPES.map((t) => (
            <button key={t.type} onClick={() => setType(type === t.type ? null : t.type)} style={{ fontFamily: "Manrope, sans-serif", fontWeight: 700, fontSize: 12, padding: "6px 12px", borderRadius: 6, cursor: "pointer", background: type === t.type ? t.color + "22" : C.surf, color: type === t.type ? t.color : C.muted, border: "1px solid " + (type === t.type ? t.color + "55" : "transparent") }}>{t.label}</button>
          ))}
        </div>
      </Panel>

      {list.length === 0 ? (
        <Panel style={{ textAlign: "center" }}><div style={{ fontFamily: "Manrope, sans-serif", fontSize: 13, color: C.muted }}>Нет раскидок под фильтр.</div></Panel>
      ) : (
        <div className="grid gap-4" style={{ gridTemplateColumns: "repeat(auto-fill, minmax(260px, 1fr))" }}>
          {list.map((g, i) => {
            const t = TYPES.find((x) => x.type === g.type);
            return (
              <Panel key={i}>
                <div className="flex gap-2 mb-2.5">
                  <Pill color={t?.color || O}>{t?.label}</Pill>
                  <Pill color={g.side === "T" ? O : "#4A90D9"}>{g.side} side</Pill>
                </div>
                <div style={{ fontFamily: "Manrope, sans-serif", fontWeight: 800, fontSize: 14, color: C.text, marginBottom: 4 }}>{g.name}</div>
                <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 12.5, color: C.muted, lineHeight: 1.5 }}>{g.desc}</div>
                <div className="flex items-center justify-center gap-2 mt-3 rounded-lg" style={{ background: C.surf, padding: "10px 0" }}>
                  <Play size={13} color={C.muted} /><span style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 10.5, color: C.muted }}>видео-лайнап</span>
                </div>
              </Panel>
            );
          })}
        </div>
      )}
    </>
  );
}
