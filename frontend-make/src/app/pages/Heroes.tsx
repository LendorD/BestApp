import { useState, useEffect } from "react";
import { C, Panel, SectionTitle, SellBlock, Pill, Meter } from "./_kit";
import { Sparkles, Star, Loader2 } from "lucide-react";
import { usePlayer } from "../../lib/store";
import { dota } from "../../lib/api";
import { heroName, heroPortrait } from "../../lib/heroes";

const CDN = "https://cdn.cloudflare.steamstatic.com/apps/dota2/images/dota_react/heroes";

// Demo pool, shown until a player is loaded.
const DEMO = [
  { name: "Anti-Mage", img: CDN + "/antimage.png", role: "Carry", wr: 64, games: 86, kda: 4.8, gpm: 612, verdict: "Сигнатурный герой — топ-фарм и конверсия лайнинга.", kind: "best" },
  { name: "Morphling", img: CDN + "/morphling.png", role: "Carry", wr: 61, games: 54, kda: 4.2, gpm: 588, verdict: "Стабильный пик, отличная выживаемость в файтах.", kind: "best" },
  { name: "Invoker", img: CDN + "/invoker.png", role: "Mid", wr: 59, games: 73, kda: 4.5, gpm: 561, verdict: "Высокий потолок, но просадка в ранней игре.", kind: "best" },
  { name: "Ember Spirit", img: CDN + "/ember_spirit.png", role: "Mid", wr: 57, games: 41, kda: 3.9, gpm: 545, verdict: "Хорош в темповых играх, слабее против контроля.", kind: "best" },
  { name: "Faceless Void", img: CDN + "/faceless_void.png", role: "Carry", wr: 44, games: 22, kda: 2.4, gpm: 498, verdict: "Проблемный: плохой тайминг хроносферы.", kind: "weak" },
  { name: "Pudge", img: CDN + "/pudge.png", role: "Offlane", wr: 41, games: 18, kda: 2.1, gpm: 360, verdict: "Минусовой винрейт — стоит ограничить пики.", kind: "weak" },
];

function mapHero(h: any, kind: string) {
  return {
    name: heroName(h.hero_id),
    img: heroPortrait(h.hero_id),
    role: h.role || "",
    wr: Math.round(h.winrate ?? 0),
    games: h.matches ?? h.games ?? 0,
    kda: Number(h.average_kda ?? h.kda ?? 0),
    gpm: h.gpm,
    verdict: "",
    kind,
  };
}

function HeroCard({ h, accent }: any) {
  const [broken, setBroken] = useState(false);
  const col = h.wr >= 55 ? C.green : h.wr < 48 ? C.red : C.muted;
  return (
    <Panel style={{ padding: 0, overflow: "hidden" }}>
      <div style={{ position: "relative", height: 116, background: C.surf }}>
        {h.img && !broken ? (
          <img src={h.img} alt={h.name} loading="lazy" onError={() => setBroken(true)}
            style={{ width: "100%", height: "100%", objectFit: "cover", display: "block" }} />
        ) : null}
        <div style={{ position: "absolute", inset: 0, background: "radial-gradient(120% 80% at 50% 0%, " + accent + "33, transparent 60%)" }} />
        <div style={{ position: "absolute", left: 0, right: 0, bottom: 0, height: 48, background: "linear-gradient(transparent, " + C.card + ")" }} />
        <span style={{ position: "absolute", top: 8, right: 8, fontFamily: "JetBrains Mono, monospace", fontSize: 11, fontWeight: 700, color: C.bg, background: col, padding: "3px 7px", borderRadius: 5 }}>{h.wr}%</span>
      </div>
      <div className="p-4">
        <div style={{ fontFamily: "Manrope, sans-serif", fontWeight: 800, fontSize: 15, color: C.text }}>{h.name}</div>
        <div style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 10.5, color: C.muted, marginBottom: 8 }}>{h.role ? h.role + " · " : ""}{h.games} игр</div>
        <Meter value={h.wr} color={col} />
        <div className="flex justify-between mt-2" style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 11.5, color: C.muted }}>
          <span>KDA {h.kda ? h.kda.toFixed(2) : "—"}</span>{h.gpm ? <span>{h.gpm} GPM</span> : null}
        </div>
        {h.verdict ? (
          <div className="rounded-lg mt-3 p-2.5" style={{ background: C.bg, border: "1px solid " + C.border }}>
            <div className="flex items-center gap-1.5 mb-1"><Sparkles size={11} color={C.gold} /><span style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 9.5, color: C.gold, letterSpacing: "0.08em" }}>AI ВЕРДИКТ</span></div>
            <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 12, color: C.text, lineHeight: 1.45 }}>{h.verdict}</div>
          </div>
        ) : null}
      </div>
    </Panel>
  );
}

export default function Heroes() {
  const { accountId, live } = usePlayer();
  const [heroes, setHeroes] = useState(DEMO);
  const [loading, setLoading] = useState(false);
  const [isLive, setIsLive] = useState(false);

  useEffect(() => {
    if (!accountId) { setHeroes(DEMO); setIsLive(false); return; }
    let cancelled = false;
    setLoading(true);
    dota.getHeroes(accountId)
      .then((res: any) => {
        if (cancelled) return;
        const best = (res?.best || []).map((h: any) => mapHero(h, "best"));
        const weak = (res?.problem || res?.weak || []).map((h: any) => mapHero(h, "weak"));
        setHeroes(best.length || weak.length ? [...best, ...weak] : DEMO);
        setIsLive(best.length > 0 || weak.length > 0);
      })
      .catch(() => { if (!cancelled) { setHeroes(DEMO); setIsLive(false); } })
      .finally(() => { if (!cancelled) setLoading(false); });
    return () => { cancelled = true; };
  }, [accountId]);

  const best = heroes.filter((h) => h.kind === "best");
  const weak = heroes.filter((h) => h.kind === "weak");

  return (
    <>
      <SellBlock
        kicker="HERO POOL · AI"
        title="Твои лучшие герои — и честный разбор, на ком ты сливаешь"
        text="GameMentor анализирует все твои игры на каждом герое: винрейт, KDA, тайминги, паттерны побед и поражений. ИИ объясняет, почему один герой приносит MMR, а другой — тянет вниз, и собирает оптимальный hero pool под твой стиль."
        bullets={["Анализ по каждому герою", "AI-вердикт сильных/слабых пиков", "Рекомендованный пул на неделю", "Сравнение с про на этом герое"]}
        cta="Собрать мой hero pool"
      />

      <SectionTitle title="Сигнатурные герои" sub={loading ? "Загрузка…" : isLive ? "По твоим последним матчам" : "Где ты реально силён"}
        right={loading ? <Loader2 size={14} className="animate-spin" color={C.green} /> : <Pill>{live ? <><Star size={11} /> live</> : <><Star size={11} /> демо</>}</Pill>} />
      <div className="grid gap-4" style={{ gridTemplateColumns: "repeat(auto-fill, minmax(220px, 1fr))" }}>
        {best.length ? best.map((h, i) => <HeroCard key={h.name + i} h={h} accent={C.green} />) : <div style={{ color: C.muted, fontSize: 13, padding: 8 }}>Нет данных по героям.</div>}
      </div>

      <SectionTitle title="Проблемные герои" sub="Кандидаты на бан из пула" right={<Pill color={C.red}>▼ минус винрейт</Pill>} />
      <div className="grid gap-4" style={{ gridTemplateColumns: "repeat(auto-fill, minmax(220px, 1fr))" }}>
        {weak.length ? weak.map((h, i) => <HeroCard key={h.name + i} h={h} accent={C.red} />) : <div style={{ color: C.muted, fontSize: 13, padding: 8 }}>Проблемных героев не найдено.</div>}
      </div>

      <Panel style={{ borderColor: C.gold + "33" }}>
        <SectionTitle title={<span className="inline-flex items-center gap-2"><Sparkles size={16} color={C.gold} /> AI-анализ пула</span>} sub="Доступно на тарифе Pro" right={<Pill color={C.gold}>◆ PRO</Pill>} />
        <div className="grid gap-3 grid-cols-1 lg:grid-cols-2">
          <div className="rounded-lg p-4" style={{ background: C.bg, border: "1px solid " + C.border, borderLeft: "3px solid " + C.green }}>
            <div style={{ fontFamily: "Manrope, sans-serif", fontWeight: 700, fontSize: 14, color: C.text, marginBottom: 6 }}>Сила: фарм-кор</div>
            <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 13, color: C.muted, lineHeight: 1.55 }}>ИИ выделит героев, на которых ты в топе брекета по GPM, и подскажет, какие пики приносят больше всего MMR.</div>
          </div>
          <div className="rounded-lg p-4" style={{ background: C.bg, border: "1px solid " + C.border, borderLeft: "3px solid " + C.red }}>
            <div style={{ fontFamily: "Manrope, sans-serif", fontWeight: 700, fontSize: 14, color: C.text, marginBottom: 6 }}>Слабость: широкий пул</div>
            <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 13, color: C.muted, lineHeight: 1.55 }}>ИИ предложит сузить пул до сигнатурных героев и назовёт первых кандидатов на бан по твоей статистике.</div>
          </div>
        </div>
        <button className="mt-4 w-full" style={{ fontFamily: "Manrope, sans-serif", fontWeight: 700, fontSize: 13, color: C.bg, background: C.gold, border: "none", borderRadius: 8, padding: "11px 0", cursor: "pointer" }}>Полный AI-отчёт по героям →</button>
      </Panel>
    </>
  );
}
