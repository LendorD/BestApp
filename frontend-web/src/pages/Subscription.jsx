import { GM, DOTA_ACCENT, CS2_ACCENT } from '../lib/theme.js'
import { Card, Kicker, Badge, Icon, Mono, Stack, SectionTitle } from '../components/primitives.jsx'

const PLANS = [
  {
    id: 'free', name: 'Free', price: '0 ₽', period: '', accent: '#8A94A6',
    features: ['Базовый дашборд', '1 AI-прогон бесплатно', 'Последние 20 матчей', 'Hero pool'],
    cta: 'Текущий план', current: true,
  },
  {
    id: 'pro', name: 'PRO', price: '499 ₽', period: '/ мес', accent: '#D4AF37', highlight: true,
    features: ['Полный дашборд + 100 матчей', 'Безлимит AI Coach', 'Pro benchmark', 'Skill radar + тренды', 'Недельные планы тренировок', 'Приоритетная синхронизация'],
    cta: 'Оформить PRO',
  },
  {
    id: 'team', name: 'Team', price: '1 990 ₽', period: '/ мес', accent: '#00D084',
    features: ['Всё из PRO ×5 игроков', 'Командная аналитика', 'Сравнение состава', 'Тренерская панель', 'Экспорт отчётов'],
    cta: 'Связаться',
  },
]

export default function Subscription({ game = 'dota' }) {
  const accent = game === 'cs2' ? CS2_ACCENT : DOTA_ACCENT

  return (
    <Stack gap={16}>
      <Card glow accent={GM.premium} pad={24} style={{ borderColor: `${GM.premium}33` }}>
        <SectionTitle
          title={<span style={{ display: 'inline-flex', alignItems: 'center', gap: 8 }}><Icon name="crown" size={18} color={GM.premium} /> Подписка</span>}
          sub="Разблокируй полную аналитику и AI Coach"
          right={<Badge color={GM.premium}>◆ PREMIUM</Badge>}
        />
      </Card>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))', gap: 16, alignItems: 'start' }}>
        {PLANS.map(plan => (
          <Card key={plan.id} glow={plan.highlight} accent={plan.accent} pad={24}
            style={{ border: `1px solid ${plan.highlight ? plan.accent + '66' : GM.border}`, position: 'relative' }}>
            {plan.highlight && (
              <div style={{ position: 'absolute', top: 16, right: 16 }}><Badge color={plan.accent} solid>ХИТ</Badge></div>
            )}
            <Kicker color={plan.accent}>{plan.name}</Kicker>
            <div style={{ display: 'flex', alignItems: 'baseline', gap: 6, margin: '12px 0 18px' }}>
              <span style={{ fontSize: 34, fontWeight: 900, letterSpacing: '-0.02em' }}>{plan.price}</span>
              <span style={{ fontSize: 13, color: GM.muted }}>{plan.period}</span>
            </div>
            <Stack gap={10}>
              {plan.features.map(f => (
                <div key={f} style={{ display: 'flex', alignItems: 'flex-start', gap: 9 }}>
                  <Icon name="check" size={16} color={plan.accent} />
                  <span style={{ fontSize: 13, color: GM.text, lineHeight: 1.4 }}>{f}</span>
                </div>
              ))}
            </Stack>
            <button disabled={plan.current} style={{
              marginTop: 20, width: '100%', padding: '12px 0', borderRadius: 8,
              border: plan.current ? `1px solid ${GM.border}` : 'none',
              background: plan.current ? 'transparent' : plan.accent,
              color: plan.current ? GM.muted : GM.bg,
              fontWeight: 800, fontSize: 14, fontFamily: 'inherit',
              cursor: plan.current ? 'default' : 'pointer',
            }}>
              {plan.cta}
            </button>
          </Card>
        ))}
      </div>

      <Card pad={18} style={{ textAlign: 'center', border: `1px dashed ${GM.border}` }}>
        <Mono style={{ fontSize: 12, color: GM.deep }}>
          Оплата подключается позже · сейчас доступен бесплатный режим со всеми демо-функциями
        </Mono>
      </Card>
    </Stack>
  )
}
