import { useState } from "react";
import { C, Panel, SectionTitle, SellBlock, Pill } from "./_kit";
import { Trophy, TrendingUp, TrendingDown } from "lucide-react";

const ROWS = [
  { rank: 1, name: "Yatoro", region: "EU", score: 96, mmr: 12450, wr: 71, up: true, you: false },
  { rank: 2, name: "Nisha", region: "EU", score: 94, mmr: 11980, wr: 68, up: true, you: false },
  { rank: 3, name: "Ame", region: "CN", score: 95, mmr: 12210, wr: 69, up: false, you: false },
  { rank: 124, name: "baumi", region: "EU", score: 74, mmr: 7840, wr: 63, up: true, you: true },
  { rank: 125, name: "Quinn", region: "EU", score: 73, mmr: 7790, wr: 60, up: false, you: false },
  { rank: 126, name: "Watson", region: "EU", score: 72, mmr: 7710, wr: 58, up: true, you: false },
];

export default function Rankings() {
  const [tab, setTab] = useState<"region" | "global">("region");
  return (
    <>
      <SellBlock
        kicker="RANKINGS"
        title="Где ты среди лучших — и сколько до следующего ранга"
        text="Живой рейтинг по региону и миру: GameMentor Score, MMR, винрейт и динамика. Сравнивай себя с топ-игроками твоего брекета и отслеживай рост от недели к неделе."
        bullets={["Рейтинг по региону и глобальный", "Твоя позиция и динамика", "Сравнение с соседями по таблице"]}
        accent={C.gold}
      />
      <Panel>
        <SectionTitle
          title="Лидерборд"
          sub="Обновляется каждые 30 минут"
          right={
            <div className="flex gap-1 p-1 rounded-lg" style={{ background: C.bg, border: "1px solid " + C.border }}>
              {(["region", "global"] as const).map((t) => (
                <button key={t} onClick={() => setTab(t)} style={{
                  fontFamily: "JetBrains Mono, monospace", fontSize: 11, fontWeight: 600, padding: "5px 12px", borderRadius: 6,
                  border: "none", cursor: "pointer", background: tab === t ? C.green : "transparent", color: tab === t ? C.bg : C.muted,
                }}>{t === "region" ? "EU" : "Global"}</button>
              ))}
            </div>
          }
        />
        <div className="overflow-x-auto">
          <div style={{ minWidth: 560 }}>
            <div className="grid items-center px-3 py-2" style={{ gridTemplateColumns: "60px 1fr 80px 90px 80px 60px", gap: 8 }}>
              {["#", "Игрок", "Score", "MMR", "Winrate", "Тренд"].map((h, i) => (
                <span key={h} style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 10, color: C.muted, letterSpacing: "0.06em", textAlign: i > 1 ? "right" : "left" }}>{h.toUpperCase()}</span>
              ))}
            </div>
            {ROWS.map((r) => (
              <div key={r.rank + r.name} className="grid items-center px-3 py-3 rounded-lg"
                style={{ gridTemplateColumns: "60px 1fr 80px 90px 80px 60px", gap: 8, marginTop: 4,
                  background: r.you ? C.green + "14" : C.bg, border: "1px solid " + (r.you ? C.green + "3a" : C.border) }}>
                <span style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 13, fontWeight: 700, color: r.rank <= 3 ? C.gold : C.muted }}>{r.rank}</span>
                <span className="flex items-center gap-2.5" style={{ minWidth: 0 }}>
                  <span className="w-7 h-7 rounded-md flex items-center justify-center shrink-0" style={{ background: C.surf, border: "1px solid " + C.border, fontFamily: "Manrope, sans-serif", fontWeight: 800, fontSize: 12, color: r.you ? C.green : C.muted }}>{r.name[0]}</span>
                  <span style={{ fontFamily: "Manrope, sans-serif", fontWeight: r.you ? 800 : 600, fontSize: 13.5, color: r.you ? C.text : C.text }}>{r.name}{r.you && <span style={{ color: C.green, marginLeft: 6, fontSize: 10, fontFamily: "JetBrains Mono, monospace" }}>ВЫ</span>}</span>
                </span>
                <span style={{ textAlign: "right", fontFamily: "JetBrains Mono, monospace", fontSize: 13, fontWeight: 700, color: r.you ? C.green : C.text }}>{r.score}</span>
                <span style={{ textAlign: "right", fontFamily: "JetBrains Mono, monospace", fontSize: 12.5, color: C.muted }}>{r.mmr.toLocaleString()}</span>
                <span style={{ textAlign: "right", fontFamily: "JetBrains Mono, monospace", fontSize: 12.5, color: C.muted }}>{r.wr}%</span>
                <span style={{ display: "flex", justifyContent: "flex-end" }}>{r.up ? <TrendingUp size={15} color={C.green} /> : <TrendingDown size={15} color={C.red} />}</span>
              </div>
            ))}
          </div>
        </div>
      </Panel>

      <div className="grid gap-4 grid-cols-1 lg:grid-cols-3">
        {[["Твой ранг", "#124", "EU · Immortal", C.green], ["До топ-100", "+340 score", "≈ 12 побед", C.gold], ["Рост за месяц", "+18 позиций", "стабильный апсет", C.blue]].map(([t, v, s, col]) => (
          <Panel key={t as string}>
            <div className="flex items-center gap-2 mb-2"><Trophy size={15} color={col as string} /><span style={{ fontFamily: "Manrope, sans-serif", fontSize: 12, color: C.muted }}>{t}</span></div>
            <div style={{ fontFamily: "JetBrains Mono, monospace", fontWeight: 700, fontSize: 22, color: C.text }}>{v}</div>
            <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 12, color: C.muted, marginTop: 2 }}>{s}</div>
          </Panel>
        ))}
      </div>
    </>
  );
}
