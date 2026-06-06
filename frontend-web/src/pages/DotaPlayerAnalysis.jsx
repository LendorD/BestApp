import { useState, useEffect } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { GM, DOTA_ACCENT } from '../lib/theme.js'
import { Kicker, Icon, Mono, Stack } from '../components/primitives.jsx'
import { ProfileHeader, ScorePanel, KpiGrid, TrendCard, RadarCard, AiInsights, MatchesTable, LeaderboardCard, TrainingGoals } from '../components/blocks.jsx'
import { MOCK_DOTA } from '../lib/mockData.js'
import { mapDotaDashboard } from '../lib/dotaMapper.js'
import { dota } from '../lib/api.js'
import ProCompare from '../components/ProCompare.jsx'

function LoadingState({ accent }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: 80, gap: 16 }}>
      <div style={{ width: 48, height: 48, border: `3px solid ${GM.border}`, borderTopColor: accent, borderRadius: '50%', animation: 'spin 0.8s linear infinite' }} />
      <div style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: 12, color: GM.muted }}>Загрузка данных игрока…</div>
      <style>{`@keyframes spin { to { transform: rotate(360deg) } }`}</style>
    </div>
  )
}

export default function DotaPlayerAnalysis() {
  const { id } = useParams()
  const nav = useNavigate()
  const accent = DOTA_ACCENT

  const [state, setState] = useState({ loading: true, data: null, demo: false })
  const [period, setPeriod] = useState('30D')

  useEffect(() => {
    if (!id) return
    let active = true
    setState({ loading: true, data: null, demo: false })
    dota.getDashboard(id, { period: period.toLowerCase() })
      .then(raw => {
        if (!active) return
        const mapped = mapDotaDashboard(raw)
        if (mapped) setState({ loading: false, data: mapped, demo: false })
        else setState({ loading: false, data: { ...MOCK_DOTA, player: { ...MOCK_DOTA.player, accountId: id } }, demo: true })
      })
      .catch(err => {
        if (!active) return
        console.warn('Dota API failed, using demo data:', err.message)
        setState({ loading: false, data: { ...MOCK_DOTA, player: { ...MOCK_DOTA.player, accountId: id } }, demo: true })
      })
    return () => { active = false }
  }, [id, period])

  if (state.loading) return <LoadingState accent={accent} />

  const d = state.data
  if (!d) return <div style={{ padding: 40, color: GM.muted }}>Ошибка загрузки данных</div>

  const live = !state.demo
  const hasRadar = !!d.radar
  const hasLeaderboard = !!d.leaderboard
  const hasMatches = (d.matches || []).length > 0
  const hasInsights = (d.insights || []).length > 0
  const hasGoals = (d.goals || []).length > 0

  return (
    <Stack gap={16}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: -4, flexWrap: 'wrap' }}>
        <button onClick={() => nav('/dota')} style={{ display: 'flex', alignItems: 'center', gap: 6, background: 'none', border: 'none', color: GM.muted, cursor: 'pointer', fontSize: 13, fontFamily: 'inherit', padding: 0 }}>
          <Icon name="back" size={16} /> Назад
        </button>
        <span style={{ color: GM.border }}>·</span>
        <Kicker color={accent}>DOTA 2 LAB / PLAYER {id}</Kicker>
        <span style={{ flex: 1 }} />
        <span style={{
          display: 'inline-flex', alignItems: 'center', gap: 7, fontFamily: "'JetBrains Mono', monospace",
          fontSize: 11, fontWeight: 700, letterSpacing: '0.08em', padding: '5px 10px', borderRadius: 6,
          color: live ? '#00D084' : GM.premium,
          background: live ? 'rgba(0,208,132,0.12)' : `${GM.premium}16`,
          border: `1px solid ${live ? 'rgba(0,208,132,0.5)' : GM.premium + '55'}`,
        }}>
          <span style={{ width: 7, height: 7, borderRadius: 999, background: live ? '#00D084' : GM.premium, boxShadow: live ? '0 0 6px #00D084' : 'none' }} />
          {live ? 'LIVE · OpenDota' : 'DEMO · нет связи с API'}
        </span>
      </div>

      <ProfileHeader d={d} accent={accent} period={period} setPeriod={setPeriod} />

      <div style={{ display: 'grid', gridTemplateColumns: 'minmax(0,5fr) minmax(0,7fr)', gap: 16 }}>
        <ScorePanel d={d} accent={accent} />
        <KpiGrid d={d} accent={accent} cols={3} />
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: hasRadar ? 'minmax(0,7fr) minmax(0,5fr)' : '1fr', gap: 16 }}>
        <TrendCard d={d} accent={accent} />
        {hasRadar ? <RadarCard d={d} accent={accent} /> : null}
      </div>

      {hasInsights ? <AiInsights d={d} accent={accent} /> : null}

      {hasMatches ? (
        hasLeaderboard ? (
          <div style={{ display: 'grid', gridTemplateColumns: 'minmax(0,7fr) minmax(0,5fr)', gap: 16 }}>
            <MatchesTable d={d} accent={accent} rows={8} />
            <LeaderboardCard d={d} accent={accent} />
          </div>
        ) : (
          <MatchesTable d={d} accent={accent} rows={8} />
        )
      ) : null}

      {hasGoals ? <TrainingGoals d={d} accent={accent} /> : null}

      <ProCompare steamId={id} accent={accent} />
    </Stack>
  )
}
