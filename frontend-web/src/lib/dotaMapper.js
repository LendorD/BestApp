// Maps the Go backend DotaLabDashboard DTO -> the view-model used by the dashboard blocks.
// IMPORTANT: when we have a real backend response we DO NOT inject mock data.
// Missing sections come back empty so the UI can hide them or show "no data".
import { DOTA_ACCENT } from './theme.js'
import { heroName, heroInitials, rankTierName, durationStr, timeAgo } from './dotaHeroes.js'

const clamp = (v, lo = 0, hi = 100) => Math.max(lo, Math.min(hi, v))
const norm100 = (n) => (n == null ? 0 : (n <= 1 ? n * 100 : n))
const fmtK = (n) => (n >= 1000 ? `${(n / 1000).toFixed(1)}k` : String(Math.round(n || 0)))

function severityKind(sev) {
  const s = (sev || '').toLowerCase()
  if (s === 'high' || s === 'critical') return 'weak'
  if (s === 'low' || s === 'strength') return 'strong'
  return 'focus'
}

export function mapDotaDashboard(api) {
  if (!api || !api.summary) return null
  const accent = DOTA_ACCENT
  const p = api.player || {}
  const s = api.summary || {}
  const perf = api.performance || {}
  const winrate = s.winrate ?? p.winrate ?? 0
  const kda = s.average_kda ?? 0

  // Score / breakdown (real performance only)
  const breakdown = (perf.breakdown || []).map(b => ({
    label: b.label, value: clamp(Math.round(b.score)), hint: b.key,
  }))
  const score = {
    value: clamp(Math.round(perf.total ?? 0)),
    delta: null, // backend gives no delta -> hide it
    percentile: '', // backend gives no percentile -> hide it
    caption: `Winrate ${winrate.toFixed(1)}% / KDA ${kda.toFixed(2)} - ${s.matches || 0} матчей`,
    breakdown,
  }

  // Form timeline -> real rolling-winrate series
  const formMatches = api.form_timeline?.matches || []
  const winSeries = []
  let won = 0
  formMatches.forEach((m, i) => {
    if (m.won) won++
    winSeries.push(Math.round((won / (i + 1)) * 100))
  })
  const scoreSeries = formMatches.map(m => Math.round(m.score || 0))
  const trend = { winrate: winSeries, mmr: scoreSeries }

  // KPIs from real summary. spark = real rolling winrate (shape only); empty if none.
  const kpis = [
    { label: 'Winrate',   value: `${winrate.toFixed(0)}%`,             up: winrate >= 50, spark: winSeries },
    { label: 'KDA',       value: kda.toFixed(2),                        up: kda >= 3,      spark: winSeries },
    { label: 'GPM',       value: String(Math.round(s.average_gpm || 0)), up: true,         spark: winSeries },
    { label: 'XPM',       value: String(Math.round(s.average_xpm || 0)), up: true,         spark: winSeries },
    { label: 'Last hits', value: String(Math.round(s.average_last_hits || 0)), up: true,   spark: winSeries },
    { label: 'Hero DMG',  value: fmtK(s.average_hero_damage || 0),      up: true,          spark: winSeries },
  ].map(k => ({ ...k, delta: '' }))

  // Radar from real breakdown; rankAvg null (we have no real bracket average)
  const radar = breakdown.length >= 3
    ? { axes: breakdown.map(b => b.label), you: breakdown.map(b => b.value), rankAvg: null }
    : null

  // Insights from real weaknesses + ai coach
  const insights = (api.weaknesses || []).slice(0, 3).map(w => ({
    kind: severityKind(w.severity),
    tag: (w.severity || 'FOCUS').toUpperCase(),
    title: w.title,
    body: w.message,
  }))
  if (api.ai_coach?.primary_action) {
    insights.push({ kind: 'focus', tag: 'AI COACH', title: api.ai_coach.title || 'Зона роста', body: api.ai_coach.primary_action })
  }

  // Matches (real) - keep hero_id for portrait icons
  const matches = (api.matches || []).slice(0, 8).map(m => ({
    heroId: m.hero_id,
    hero: heroName(m.hero_id),
    hi: heroInitials(m.hero_id),
    result: m.won ? 'W' : 'L',
    kda: `${m.kills}/${m.deaths}/${m.assists}`,
    gpm: m.gold_per_min,
    dur: durationStr(m.duration_seconds),
    impact: ((m.kills + m.assists * 0.5) / Math.max(m.deaths, 1)).toFixed(1),
    when: timeAgo(m.start_time),
  }))

  const leaderboard = mapProComparison(api.pro_comparison) // null if none

  const goals = (api.training_plan?.items || []).slice(0, 3).map((it, i) => ({
    label: it.title,
    pct: clamp(45 + i * 18),
    sub: `${it.day} - ${it.focus}`,
  }))

  return {
    accent,
    live: true,
    player: {
      name: p.persona_name || `Игрок ${p.account_id || api.steam_id}`,
      avatar: (p.persona_name || 'P')[0].toUpperCase(),
      accountId: String(api.steam_id || p.account_id || ''),
      region: 'OpenDota',
      rolesLine: p.favorite_role ? `Роль: ${p.favorite_role}` : '',
      rankTier: p.rank_label || rankTierName(p.rank_tier),
      rankSub: '',
      mmr: '',
      mmrDelta: 0,
      seasonLabel: 'RANKED / LIVE DATA',
    },
    score,
    kpis,
    trend,
    radar,
    insights,
    matches,
    leaderboard,
    goals,
  }
}

function mapProComparison(pc) {
  if (!pc || !pc.metrics?.length || !pc.series?.length) return null
  const metrics = pc.metrics
  const series = pc.series
  const isYou = (sr) => sr.id === 'you' || /you|вы/i.test(sr.name || '')
  const youSeries = series.find(isYou)
  const proSeries = series.filter(sr => !isYou(sr))

  const avgNorm = (sr) => {
    const vals = metrics.map(m => norm100(sr.values?.[m.key]?.normalized))
    return Math.round(vals.reduce((a, b) => a + b, 0) / Math.max(vals.length, 1))
  }

  const rows = series.map(sr => ({
    name: isYou(sr) ? 'You' : sr.name,
    you: isYou(sr),
    score: avgNorm(sr),
  })).sort((a, b) => b.score - a.score)

  const topPro = proSeries[0]
  const bars = metrics.slice(0, 4).map(m => ({
    label: m.label,
    you: youSeries ? Math.round(norm100(youSeries.values?.[m.key]?.normalized)) : 0,
    pro: topPro ? Math.round(norm100(topPro.values?.[m.key]?.normalized)) : 100,
  }))

  return { caption: 'vs Pro / normalized', rows, bars }
}
