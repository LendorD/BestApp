import { GM, DOTA_ACCENT, CS2_ACCENT } from '../lib/theme.js'
import { Card, Kicker, Badge, Icon, Mono, Stack, SectionTitle, Meter, Delta } from '../components/primitives.jsx'

const DOTA_META = [
  { tier: 'S', heroes: [['Juggernaut', 56], ['Phantom Assassin', 54], ['Mars', 53]] },
  { tier: 'A', heroes: [['Invoker', 52], ['Lina', 51], ['Storm Spirit', 51], ['Ursa', 50]] },
  { tier: 'B', heroes: [['Pudge', 49], ['Sniper', 48], ['Slark', 48]] },
]
const CS2_META = [
  { tier: 'S', heroes: [['Mirage', 53], ['Inferno', 52], ['Ancient', 51]] },
  { tier: 'A', heroes: [['Nuke', 50], ['Anubis', 49], ['Vertigo', 49]] },
  { tier: 'B', heroes: [['Dust II', 48], ['Train', 47]] },
]
const TIER_COLOR = { S: '#FF4D61', A: '#FF6B00', B: '#D4AF37', C: '#8A94A6' }

export default function Meta({ game = 'dota' }) {
  const accent = game === 'cs2' ? CS2_ACCENT : DOTA_ACCENT
  const meta = game === 'cs2' ? CS2_META : DOTA_META
  const unit = game === 'cs2' ? 'карты' : 'герои'

  return (
    <Stack gap={16}>
      <Card glow accent={accent} pad={20} style={{ borderColor: `${accent}33` }}>
        <SectionTitle
          title={<span style={{ display: 'inline-flex', alignItems: 'center', gap: 8 }}><Icon name="graph" size={18} color={accent} /> Мета</span>}
          sub={`Актуальный тир-лист (${unit}) по винрейту патча`}
          right={<Badge color={accent}>PATCH 7.39</Badge>}
        />
      </Card>

      {meta.map(({ tier, heroes }) => (
        <Card key={tier} pad={18}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
            <div style={{ width: 48, height: 48, borderRadius: 10, background: `${TIER_COLOR[tier]}1c`, border: `1px solid ${TIER_COLOR[tier]}`, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 22, fontWeight: 900, color: TIER_COLOR[tier], flexShrink: 0 }}>{tier}</div>
            <div style={{ flex: 1, display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(180px, 1fr))', gap: 10 }}>
              {heroes.map(([name, wr]) => (
                <div key={name} style={{ background: GM.bg, border: `1px solid ${GM.border}`, borderRadius: 8, padding: '10px 12px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 6 }}>
                    <span style={{ fontSize: 13, fontWeight: 700, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{name}</span>
                    <Mono style={{ fontSize: 12, fontWeight: 700, color: wr >= 52 ? accent : GM.muted }}>{wr}%</Mono>
                  </div>
                  <Meter value={wr} accent={wr >= 52 ? accent : GM.muted} />
                </div>
              ))}
            </div>
          </div>
        </Card>
      ))}
    </Stack>
  )
}
