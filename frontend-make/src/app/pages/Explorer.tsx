import { useEffect, useState } from "react";
import { Panel, SectionTitle, Pill, C } from "./_kit";
import { Database, Loader2, Search, AlertTriangle, Activity, Crown } from "lucide-react";
import { usePlayer } from "../../lib/store";
import { dota } from "../../lib/api";
import { heroName, heroPortrait } from "../../lib/heroes";

const mono = "JetBrains Mono, monospace";

function dur(s: number) {
  if (!s) return "—";
  const m = Math.floor(s / 60);
  return `${m}:${String(s % 60).padStart(2, "0")}`;
}

function HeroCell({ id }: { id: number }) {
  const [broken, setBroken] = useState(false);
  const img = heroPortrait(id);
  return (
    <div className="flex items-center gap-2" style={{ minWidth: 0 }}>
      <div style={{ width: 34, height: 19, borderRadius: 3, overflow: "hidden", background: C.surf, flexShrink: 0 }}>
        {img && !broken ? <img src={img} alt="" onError={() => setBroken(true)} style={{ width: "100%", height: "100%", objectFit: "cover" }} /> : null}
      </div>
      <span style={{ fontSize: 12.5, color: C.text, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{heroName(id)}</span>
    </div>
  );
}

function Stat({ label, value, color = C.text }: { label: string; value: any; color?: string }) {
  return (
    <div className="rounded-lg p-3" style={{ background: C.bg, border: "1px solid " + C.border }}>
      <div style={{ fontFamily: mono, fontSize: 18, fontWeight: 700, color }}>{value}</div>
      <div style={{ fontSize: 11.5, color: C.muted, marginTop: 2 }}>{label}</div>
    </div>
  );
}

function impColor(imp: number) {
  return imp > 10 ? C.green : imp < -10 ? C.red : C.muted;
}

export default function Explorer() {
  const { accountId } = usePlayer();
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState("");

  useEffect(() => {
    if (!accountId) { setData(null); return; }
    let cancelled = false;
    setLoading(true); setErr("");
    dota.explore(accountId)
      .then((d: any) => { if (!cancelled) setData(d); })
      .catch((e: any) => { if (!cancelled) setErr(e?.message || "Ошибка загрузки"); })
      .finally(() => { if (!cancelled) setLoading(false); });
    return () => { cancelled = true; };
  }, [accountId]);

  const od = data?.opendota;
  const st = data?.stratz;

  return (
    <div className="flex flex-col gap-4">
      <Panel style={{ borderColor: C.blue + "33" }}>
        <SectionTitle
          title={<span className="inline-flex items-center gap-2"><Database size={16} color={C.blue} /> Data Explorer</span>}
          sub="Все данные, которые мы сейчас можем собрать по игроку из OpenDota и Stratz"
          right={accountId ? <Pill color={C.blue}>ID {accountId}</Pill> : null}
        />
        <div style={{ fontSize: 12.5, color: C.muted, lineHeight: 1.5 }}>
          Это технический просмотр источников — чтобы решить, что и как выводить на сайт.
          Данные берутся для текущего игрока (из профиля или из поиска).
        </div>
      </Panel>

      {!accountId ? (
        <Panel>
          <div className="flex items-center gap-2" style={{ color: C.muted, fontSize: 13.5 }}>
            <Search size={15} /> Укажи Dota ID в профиле или найди игрока через поиск — тогда здесь появятся данные.
          </div>
        </Panel>
      ) : loading ? (
        <Panel><div className="flex items-center gap-2" style={{ color: C.muted }}><Loader2 size={15} className="animate-spin" color={C.green} /> Загружаю из OpenDota и Stratz…</div></Panel>
      ) : err ? (
        <Panel><div className="flex items-center gap-2" style={{ color: C.red }}><AlertTriangle size={15} /> {err}</div></Panel>
      ) : (
        <>
          {/* ===== OpenDota ===== */}
          <Panel>
            <SectionTitle title="OpenDota" sub="Открытый источник, без ключа" right={<Pill color={C.green}>live</Pill>} />

            {od?.profile && (
              <div className="flex items-center gap-3 mb-4">
                {od.profile.avatar ? <img src={od.profile.avatar} alt="" style={{ width: 44, height: 44, borderRadius: 10 }} /> : null}
                <div>
                  <div style={{ fontSize: 15, fontWeight: 800, color: C.text }}>{od.profile.name || "—"}</div>
                  <div style={{ fontSize: 12, color: C.muted }}>rank_tier: {od.profile.rank_tier ?? "—"}{od.profile.profile_url ? " · Steam" : ""}</div>
                </div>
              </div>
            )}

            <div className="grid gap-2.5 mb-4" style={{ gridTemplateColumns: "repeat(auto-fit, minmax(120px, 1fr))" }}>
              {od?.win_loss && <Stat label="Винрейт" value={od.win_loss.winrate_pct.toFixed(1) + "%"} color={C.green} />}
              {od?.win_loss && <Stat label="W / L" value={`${od.win_loss.win} / ${od.win_loss.lose}`} />}
              {(od?.averages || []).map((a: any) => <Stat key={a.label} label={a.label} value={a.value} />)}
            </div>

            {od?.lanes?.length ? (
              <div className="mb-4">
                <div style={{ fontSize: 12, color: C.muted, marginBottom: 6 }}>Распределение по лайнам (игр):</div>
                <div className="flex flex-wrap gap-2">
                  {od.lanes.map((l: any) => <Pill key={l.label} color={C.blue}>{l.label}: {l.value}</Pill>)}
                </div>
              </div>
            ) : null}

            {od?.top_heroes?.length ? (
              <div className="mb-4">
                <div style={{ fontSize: 12, color: C.muted, marginBottom: 8 }}>Топ героев по числу игр:</div>
                <div className="grid gap-2" style={{ gridTemplateColumns: "repeat(auto-fill, minmax(190px, 1fr))" }}>
                  {od.top_heroes.map((h: any) => (
                    <div key={h.hero_id} className="flex items-center justify-between rounded-lg px-2.5 py-2" style={{ background: C.bg, border: "1px solid " + C.border }}>
                      <HeroCell id={h.hero_id} />
                      <span style={{ fontFamily: mono, fontSize: 11.5, color: h.winrate_pct >= 50 ? C.green : C.red, whiteSpace: "nowrap" }}>{h.winrate_pct}% · {h.games}и</span>
                    </div>
                  ))}
                </div>
              </div>
            ) : null}

            {od?.recent_matches?.length ? (
              <div>
                <div style={{ fontSize: 12, color: C.muted, marginBottom: 8 }}>Последние матчи:</div>
                <div className="overflow-x-auto">
                  <table style={{ width: "100%", borderCollapse: "collapse", fontFamily: mono, fontSize: 12 }}>
                    <thead>
                      <tr style={{ color: C.muted, textAlign: "left" }}>
                        <th style={{ padding: "6px 8px" }}>Герой</th><th>Рез.</th><th>K/D/A</th><th>GPM</th><th>XPM</th><th>Длит.</th>
                      </tr>
                    </thead>
                    <tbody>
                      {od.recent_matches.map((m: any) => (
                        <tr key={m.match_id} style={{ borderTop: "1px solid " + C.border, color: C.text }}>
                          <td style={{ padding: "6px 8px" }}><HeroCell id={m.hero_id} /></td>
                          <td style={{ color: m.won ? C.green : C.red }}>{m.won ? "W" : "L"}</td>
                          <td>{m.kills}/{m.deaths}/{m.assists}</td>
                          <td>{m.gpm}</td><td>{m.xpm}</td><td>{dur(m.duration_seconds)}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            ) : null}

            {od?.notes?.length ? <div style={{ marginTop: 10, fontSize: 11.5, color: C.muted }}>{od.notes.join(" · ")}</div> : null}
          </Panel>

          {/* ===== Stratz ===== */}
          <Panel style={{ borderColor: st?.enabled ? C.gold + "33" : C.border }}>
            <SectionTitle
              title={<span className="inline-flex items-center gap-2"><Activity size={16} color={C.gold} /> Stratz</span>}
              sub="GraphQL · нужен токен · метрика IMP"
              right={<Pill color={st?.enabled ? C.gold : C.muted}>{st?.enabled ? "токен есть" : "нет токена"}</Pill>}
            />

            {!st?.enabled ? (
              <div style={{ color: C.muted, fontSize: 13 }}>Токен Stratz не задан в окружении бэкенда (STRATZ_API_KEY).</div>
            ) : st?.error ? (
              <div className="flex items-center gap-2" style={{ color: C.red, fontSize: 13 }}><AlertTriangle size={15} /> {st.error}</div>
            ) : st?.player ? (
              <>
                <div className="grid gap-2.5 mb-4" style={{ gridTemplateColumns: "repeat(auto-fit, minmax(130px, 1fr))" }}>
                  <Stat label="Имя" value={st.player.name || "—"} />
                  <Stat label="Всего матчей" value={st.player.match_count} />
                  <Stat label="Винрейт (всё время)" value={st.player.winrate_pct.toFixed(1) + "%"} color={C.green} />
                  {st.player.behavior_score ? <Stat label="Behavior score" value={st.player.behavior_score} color={C.gold} /> : null}
                  {st.player.avg_imp != null ? <Stat label="Средний IMP" value={st.player.avg_imp.toFixed(1)} color={impColor(st.player.avg_imp)} /> : null}
                </div>

                {st.player.recent_matches?.length ? (
                  <div>
                    <div style={{ fontSize: 12, color: C.muted, marginBottom: 8 }}>Последние матчи с IMP (вклад в победу, −100…+100):</div>
                    <div className="overflow-x-auto">
                      <table style={{ width: "100%", borderCollapse: "collapse", fontFamily: mono, fontSize: 12 }}>
                        <thead>
                          <tr style={{ color: C.muted, textAlign: "left" }}>
                            <th style={{ padding: "6px 8px" }}>Герой</th><th>Рез.</th><th>IMP</th><th>K/D/A</th><th>Networth</th><th>Длит.</th>
                          </tr>
                        </thead>
                        <tbody>
                          {st.player.recent_matches.map((m: any) => (
                            <tr key={m.match_id} style={{ borderTop: "1px solid " + C.border, color: C.text }}>
                              <td style={{ padding: "6px 8px" }}><HeroCell id={m.hero_id} /></td>
                              <td style={{ color: m.win ? C.green : C.red }}>{m.win ? "W" : "L"}</td>
                              <td style={{ color: impColor(m.imp), fontWeight: 700 }}>{m.imp > 0 ? "+" + m.imp : m.imp}</td>
                              <td>{m.kills}/{m.deaths}/{m.assists}</td>
                              <td>{m.networth ? m.networth.toLocaleString("ru-RU") : "—"}</td>
                              <td>{dur(m.duration_seconds)}</td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  </div>
                ) : null}

                {st.player.note ? <div style={{ marginTop: 10, fontSize: 11.5, color: C.muted }}>{st.player.note}</div> : null}
              </>
            ) : (
              <div style={{ color: C.muted, fontSize: 13 }}>Нет данных от Stratz.</div>
            )}
          </Panel>

          <p style={{ fontSize: 11.5, color: C.muted, textAlign: "center" }}>
            Это сырой обзор источников. Дальше решим, какие из этих данных и в каком виде вынести на боевые страницы.
          </p>
        </>
      )}
    </div>
  );
}
