import { GM, DOTA_ACCENT, CS2_ACCENT } from '../lib/theme.js'
import { Card, Kicker, Badge, Icon, Mono, Stack, SectionTitle, Meter } from '../components/primitives.jsx'
import { MOCK_DOTA, MOCK_CS2 } from '../lib/mockData.js'

const PLAN = {
  dota: [
    { day: 'ПН', title: 'Ластхит-дрилл', focus: '10 мин practice tool, цель 78 CS к 10:00' },
    { day: 'ВТ', title: 'Разбор 2 поражений', focus: 'Отметить тайминги потери темпа' },
    { day: 'СР', title: 'Вардинг по рунам', focus: '1.4 деварда / 10 мин' },
    { day: 'ЧТ', title: '3 ранкед-матча', focus: 'Фокус на конвертацию файтов в объекты' },
    { day: 'ПТ', title: 'Hero pool', focus: 'Закрепить 2 лучших керри' },
    { day: 'СБ', title: 'AI Coach review', focus: 'Сверить прогресс по слабым местам' },
  ],
  cs2: [
    { day: 'ПН', title: 'Aim-дрилл', focus: 'Aim Botz 15 мин + recoil master' },
    { day: 'ВТ', title: 'Smoke-сеты', focus: '3 дефолт-смоука на текущей карте' },
    { day: 'СР', title: 'Prefire практика', focus: 'Common angles на 2 картах' },
    { day: 'ЧТ', title: '3 Premier матча', focus: 'Трейд перед энтри' },
    { day: 'ПТ', title: 'Разбор демок', focus: 'Найти un-traded смерти' },
    { day: 'СБ', title: 'Clutch практика', focus: '1vX ретейк сценарии' },
  ],
}

export default function Training({ game = 'dota' }) {
  const accent = game === 'cs2' ? CS2_ACCENT : DOTA_ACCENT
  const d = game === 'cs2' ? MOCK_CS2 : MOCK_DOTA
  const plan = PLAN[game]

  return (
    <Stack gap={16}>
      <Card glow accent={accent} pad={20} style={{ borderColor: `${accent}33` }}>
        <SectionTitle
          title={<span style={{ display: 'inline-flex', alignItems: 'center', gap: 8 }}><Icon name="target" size={18} color={accent} /> Тренировки</span>}
          sub="Недельный план улучшения, основанный на твоих слабых местах"
          right={<Badge color={accent}>{game === 'cs2' ? 'CS2' : 'DOTA 2'}</Badge>}
        />
      </Card>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: 12 }}>
        {d.goals.map(g => (
          <Card key={g.label} pad={16}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 8, marginBottom: 10 }}>
              <span style={{ fontSize: 13, fontWeight: 700, lineHeight: 1.3 }}>{g.label}</span>
              <Mono style={{ fontSize: 15, fontWeight: 700, color: accent }}>{g.pct}%</Mono>
            </div>
            <Meter value={g.pct} accent={accent} glow />
            <Mono style={{ fontSize: 10.5, color: GM.deep, marginTop: 8, display: 'block' }}>{g.sub}</Mono>
          </Card>
        ))}
      </div>

      <Card pad={20}>
        <SectionTitle title="Расписание недели" sub="6 сессий · ~20 мин в день" right={<Mono style={{ fontSize: 11, color: GM.deep }}>WEEK 1</Mono>} />
        <Stack gap={8}>
          {plan.map(item => (
            <div key={item.day} style={{ display: 'flex', alignItems: 'center', gap: 14, padding: '12px 14px', background: GM.bg, border: `1px solid ${GM.border}`, borderRadius: 8 }}>
              <div style={{ width: 40, height: 40, borderRadius: 8, background: `${accent}14`, border: `1px solid ${accent}3a`, display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: "'JetBrains Mono', monospace", fontSize: 12, fontWeight: 800, color: accent, flexShrink: 0 }}>{item.day}</div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 13.5, fontWeight: 800 }}>{item.title}</div>
                <div style={{ fontSize: 12, color: GM.muted, marginTop: 2 }}>{item.focus}</div>
              </div>
              <Icon name="check" size={18} color={GM.deep} />
            </div>
          ))}
        </Stack>
      </Card>
    </Stack>
  )
}
