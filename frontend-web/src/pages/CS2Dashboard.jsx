import { useState } from 'react'
import { GM, CS2_ACCENT } from '../lib/theme.js'
import { Card, Kicker, Badge, Icon, Mono, Stack } from '../components/primitives.jsx'
import { ProfileHeader, ScorePanel, KpiGrid, TrendCard, RadarCard, AiInsights, MatchesTable, LeaderboardCard, TrainingGoals } from '../components/blocks.jsx'
import { MOCK_CS2 } from '../lib/mockData.js'

export default function CS2Dashboard() {
  const [period, setPeriod] = useState('30D')
  const accent = CS2_ACCENT
  const d = { ...MOCK_CS2, accent }

  return (
    <Stack gap={16}>
      <ProfileHeader d={d} accent={accent} period={period} setPeriod={setPeriod} />

      <div style={{ display: 'grid', gridTemplateColumns: 'minmax(0,5fr) minmax(0,7fr)', gap: 16 }}>
        <ScorePanel d={d} accent={accent} />
        <KpiGrid d={d} accent={accent} cols={3} />
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'minmax(0,7fr) minmax(0,5fr)', gap: 16 }}>
        <TrendCard d={d} accent={accent} />
        <RadarCard d={d} accent={accent} />
      </div>

      <AiInsights d={d} accent={accent} />

      <div style={{ display: 'grid', gridTemplateColumns: 'minmax(0,7fr) minmax(0,5fr)', gap: 16 }}>
        <MatchesTable d={d} accent={accent} rows={7} />
        <LeaderboardCard d={d} accent={accent} />
      </div>

      <TrainingGoals d={d} accent={accent} />
    </Stack>
  )
}
