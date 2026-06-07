import { useState } from "react";
import { Panel, SectionTitle, Pill, C } from "./_kit";
import { Play, Loader2, ChevronDown, ChevronRight, Info } from "lucide-react";
import { usePlayer } from "../../lib/store";
import { rawRequest } from "../../lib/api";

type EP = { id: string; label: string; method: "GET" | "POST"; path: (acc: string) => string; group: string; auth?: boolean; body?: (acc: string) => any };

const ENDPOINTS: EP[] = [
  // --- OpenDota + Stratz (наш агрегатор) ---
  { id: "explorer", label: "Explorer (OpenDota+Stratz)", method: "GET", group: "Агрегаты", path: (a) => `/dota/explorer/${a}` },
  { id: "metrics30", label: "Metrics · 30 дней", method: "GET", group: "Агрегаты", path: (a) => `/dota/metrics/${a}?days=30&limit=80` },
  { id: "metricsAll", label: "Metrics · всё (200 игр)", method: "GET", group: "Агрегаты", path: (a) => `/dota/metrics/${a}?limit=200` },

  // --- OpenDota RAW (вся история игрока для выбора метрик) ---
  { id: "rawMatches", label: "RAW · matches (500 игр, проекции)", method: "GET", group: "OpenDota RAW", path: (a) => `/dota/raw/${a}/matches?limit=500` },
  { id: "rawTotals", label: "RAW · totals (средние за всё время)", method: "GET", group: "OpenDota RAW", path: (a) => `/dota/raw/${a}/totals` },
  { id: "rawHeroes", label: "RAW · heroes (винрейт по героям)", method: "GET", group: "OpenDota RAW", path: (a) => `/dota/raw/${a}/heroes` },
  { id: "rawCounts", label: "RAW · counts (лайны/режимы)", method: "GET", group: "OpenDota RAW", path: (a) => `/dota/raw/${a}/counts` },
  { id: "rawWl", label: "RAW · win/loss", method: "GET", group: "OpenDota RAW", path: (a) => `/dota/raw/${a}/wl` },
  { id: "rawRatings", label: "RAW · ratings (MMR/ранг по времени)", method: "GET", group: "OpenDota RAW", path: (a) => `/dota/raw/${a}/ratings` },
  { id: "rawRankings", label: "RAW · rankings (перцентиль по героям)", method: "GET", group: "OpenDota RAW", path: (a) => `/dota/raw/${a}/rankings` },
  { id: "rawPeers", label: "RAW · peers (с кем играет)", method: "GET", group: "OpenDota RAW", path: (a) => `/dota/raw/${a}/peers` },
  { id: "rawWardmap", label: "RAW · wardmap (вижн)", method: "GET", group: "OpenDota RAW", path: (a) => `/dota/raw/${a}/wardmap` },
  { id: "rawHistKills", label: "RAW · histogram kills", method: "GET", group: "OpenDota RAW", path: (a) => `/dota/raw/${a}/histograms-kills` },
  { id: "rawHistGpm", label: "RAW · histogram GPM", method: "GET", group: "OpenDota RAW", path: (a) => `/dota/raw/${a}/histograms-gpm` },

  // --- Dota player (сырые данные OpenDota) ---
  { id: "pProfile", label: "Player · profile", method: "GET", group: "Dota player", path: (a) => `/dota/player/${a}/profile` },
  { id: "pMatches", label: "Player · matches", method: "GET", group: "Dota player", path: (a) => `/dota/player/${a}/matches` },
  { id: "pHeroes", label: "Player · heroes", method: "GET", group: "Dota player", path: (a) => `/dota/player/${a}/heroes` },

  // --- Lab / statistics ---
  { id: "labDash", label: "Lab · dashboard", method: "GET", group: "Lab (statistics)", path: (a) => `/dota/lab/players/${a}/dashboard` },
  { id: "labPro", label: "Lab · pro-comparison", method: "GET", group: "Lab (statistics)", path: (a) => `/dota/lab/players/${a}/pro-comparison` },
  { id: "labHeroes", label: "Lab · heroes", method: "GET", group: "Lab (statistics)", path: (a) => `/dota/lab/players/${a}/heroes` },
  { id: "labForm", label: "Lab · form", method: "GET", group: "Lab (statistics)", path: (a) => `/dota/lab/players/${a}/form` },
  { id: "labWeak", label: "Lab · weaknesses", method: "GET", group: "Lab (statistics)", path: (a) => `/dota/lab/players/${a}/weaknesses` },
  { id: "labPreview", label: "Lab · ai-coach-preview", method: "GET", group: "Lab (statistics)", path: (a) => `/dota/lab/players/${a}/ai-coach-preview` },

  // --- AI coach ---
  { id: "aiLatest", label: "AI · latest report", method: "GET", group: "AI Coach", path: (a) => `/ai-coach/dota/player/${a}/latest` },
  { id: "aiReview", label: "AI · review (генерит, LLM)", method: "POST", group: "AI Coach", path: (a) => `/ai-coach/dota/player/${a}/review` },

  // --- Global (без игрока) ---
  { id: "health", label: "Health", method: "GET", group: "Прочее", path: () => `/health` },
  { id: "plans", label: "Billing · plans", method: "GET", group: "Прочее", path: () => `/billing/plans` },
  { id: "cs2maps", label: "CS2 · maps", method: "GET", group: "Прочее", path: () => `/cs2/maps` },
  { id: "cs2nades", label: "CS2 · grenades", method: "GET", group: "Прочее", path: () => `/cs2/grenades` },
  { id: "authMe", label: "Auth · me (нужен вход)", method: "GET", group: "Прочее", auth: true, path: () => `/auth/me` },
  { id: "usersMe", label: "Users · me/profile (вход)", method: "GET", group: "Прочее", auth: true, path: () => `/users/me/profile` },
  { id: "sub", label: "Billing · subscription (вход)", method: "GET", group: "Прочее", auth: true, path: () => `/billing/subscription` },
  { id: "resolve", label: "Identity · resolve (POST)", method: "POST", group: "Прочее", path: () => `/identity/dota/resolve`, body: (a) => ({ input: a }) },
];

const GROUPS = ["Агрегаты", "OpenDota RAW", "Dota player", "Lab (statistics)", "AI Coach", "Прочее"];

function statusColor(s: number) {
  if (s >= 200 && s < 300) return C.green;
  if (s === 0) return C.muted;
  if (s >= 400 && s < 500) return C.gold;
  return C.red;
}

export default function ApiProbe() {
  const { accountId } = usePlayer();
  const [acc, setAcc] = useState(accountId || "369102305");
  const [results, setResults] = useState<Record<string, any>>({});
  const [running, setRunning] = useState<Record<string, boolean>>({});
  const [open, setOpen] = useState<Record<string, boolean>>({});
  const [allBusy, setAllBusy] = useState(false);

  const runOne = async (ep: EP) => {
    setRunning((r) => ({ ...r, [ep.id]: true }));
    try {
      const opts: RequestInit = { method: ep.method };
      if (ep.body) opts.body = JSON.stringify(ep.body(acc));
      const res = await rawRequest(ep.path(acc), opts);
      setResults((r) => ({ ...r, [ep.id]: res }));
      setOpen((o) => ({ ...o, [ep.id]: true }));
    } catch (e: any) {
      setResults((r) => ({ ...r, [ep.id]: { status: 0, ok: false, ms: 0, body: { error: String(e?.message || e) } } }));
    } finally {
      setRunning((r) => ({ ...r, [ep.id]: false }));
    }
  };

  const runAllGet = async () => {
    setAllBusy(true);
    for (const ep of ENDPOINTS.filter((e) => e.method === "GET")) {
      // последовательно, чтобы не упереться в лимит OpenDota и видеть порядок в Network
      // eslint-disable-next-line no-await-in-loop
      await runOne(ep);
    }
    setAllBusy(false);
  };

  return (
    <div className="flex flex-col gap-4">
      <Panel style={{ borderColor: C.blue + "33" }}>
        <SectionTitle title="API Тест — что отдаёт бэкенд" sub="Каждая кнопка — отдельный запрос (видно во вкладке Network)" right={<Pill color={C.blue}>DEV</Pill>} />
        <div className="flex gap-2.5 flex-wrap items-center">
          <input value={acc} onChange={(e) => setAcc(e.target.value)} placeholder="Dota account id"
            style={{ background: C.surf, border: "1px solid " + C.border, borderRadius: 9, padding: "10px 12px", color: C.text, fontFamily: "JetBrains Mono, monospace", fontSize: 13, width: 200, outline: "none" }} />
          <button onClick={runAllGet} disabled={allBusy}
            style={{ display: "inline-flex", alignItems: "center", gap: 8, background: C.green, color: C.bg, border: "none", borderRadius: 9, padding: "10px 18px", cursor: allBusy ? "default" : "pointer", fontFamily: "Manrope, sans-serif", fontWeight: 800, fontSize: 13 }}>
            {allBusy ? <Loader2 size={15} className="animate-spin" /> : <Play size={15} />} Запустить все GET
          </button>
          <span style={{ fontFamily: "Manrope, sans-serif", fontSize: 12, color: C.muted }}>POST (review/resolve) — кнопкой по отдельности.</span>
        </div>
      </Panel>

      {/* Dotabuff note */}
      <Panel style={{ borderColor: C.gold + "33" }}>
        <div className="flex items-start gap-2.5">
          <Info size={16} color={C.gold} style={{ marginTop: 1, flexShrink: 0 }} />
          <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 13, color: C.text, lineHeight: 1.55 }}>
            <b>Про Dotabuff:</b> у него нет публичного API, и он блокирует автоматический сбор (anti-bot). Подключить его как источник нельзя без нарушения их правил и хрупкого скрейпинга. Те же данные (матчи, герои, тайминги) мы уже берём из <b>OpenDota</b> (открытые данные) и <b>Stratz</b> (включая IMP) — это полноценная замена Dotabuff.
          </div>
        </div>
      </Panel>

      {GROUPS.map((g) => (
        <div key={g} className="flex flex-col gap-2.5">
          <div style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 11, letterSpacing: "0.1em", color: C.muted, marginTop: 4 }}>{g.toUpperCase()}</div>
          {ENDPOINTS.filter((e) => e.group === g).map((ep) => {
            const res = results[ep.id];
            const isOpen = open[ep.id];
            return (
              <div key={ep.id} className="rounded-xl" style={{ background: C.card, border: "1px solid " + C.border }}>
                <div className="flex items-center gap-3 px-4 py-3 flex-wrap">
                  <span style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 10.5, fontWeight: 700, color: ep.method === "POST" ? C.gold : C.green, border: "1px solid " + (ep.method === "POST" ? C.gold : C.green) + "44", borderRadius: 6, padding: "2px 7px" }}>{ep.method}</span>
                  <div className="flex-1 min-w-0">
                    <div style={{ fontFamily: "Manrope, sans-serif", fontSize: 13, fontWeight: 600, color: C.text }}>{ep.label}</div>
                    <div style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 10.5, color: C.muted, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{ep.path(acc)}</div>
                  </div>
                  {res ? (
                    <span style={{ fontFamily: "JetBrains Mono, monospace", fontSize: 11, color: statusColor(res.status) }}>{res.status} · {res.ms}ms</span>
                  ) : null}
                  {res ? (
                    <button onClick={() => setOpen((o) => ({ ...o, [ep.id]: !isOpen }))}
                      style={{ background: "transparent", border: "none", cursor: "pointer", color: C.muted, display: "flex", alignItems: "center" }}>
                      {isOpen ? <ChevronDown size={16} /> : <ChevronRight size={16} />}
                    </button>
                  ) : null}
                  <button onClick={() => runOne(ep)} disabled={running[ep.id]}
                    style={{ display: "inline-flex", alignItems: "center", gap: 6, background: C.surf, border: "1px solid " + C.border, color: C.text, borderRadius: 8, padding: "7px 12px", cursor: "pointer", fontFamily: "Manrope, sans-serif", fontSize: 12, fontWeight: 600 }}>
                    {running[ep.id] ? <Loader2 size={13} className="animate-spin" /> : <Play size={13} color={C.green} />} Запустить
                  </button>
                </div>
                {res && isOpen ? (
                  <pre style={{ margin: 0, padding: "12px 14px", borderTop: "1px solid " + C.border, background: C.bg, color: C.text, fontFamily: "JetBrains Mono, monospace", fontSize: 11.5, lineHeight: 1.5, maxHeight: 360, overflow: "auto", whiteSpace: "pre-wrap", wordBreak: "break-word" }}>
                    {JSON.stringify(res.body, null, 2)}
                  </pre>
                ) : null}
              </div>
            );
          })}
        </div>
      ))}
    </div>
  );
}
