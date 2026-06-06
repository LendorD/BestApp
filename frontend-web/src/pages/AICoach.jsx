import { useState } from 'react'
import { GM, DOTA_ACCENT, CS2_ACCENT } from '../lib/theme.js'
import { Card, Kicker, Badge, Icon, Mono, SectionTitle, Stack } from '../components/primitives.jsx'
import { aiCoach } from '../lib/api.js'
import { profile } from '../lib/storage.js'

const DEMO_REPORT = {
  demo: true,
  created_at: '2026-06-04',
  summary: 'Демо-отчёт. Подключи нейросеть (AI_PROVIDER, AI_API_KEY, AI_MODEL в .env бэкенда), чтобы получать живой разбор по твоим матчам.',
  strengths: ['Сильный ранний фарм — GPM @10 в топ 8% брекета', 'Высокая конверсия лайнинга', 'Стабильный KDA на коре'],
  weaknesses: ['Низкий vision score (варды/деварды)', 'Преимущество не конвертируется в объекты', 'Просадка в поздней игре'],
  main_mistakes: ['Нет давления после выигранных файтов', 'Поздние смоук-ганки', 'Мало девардов на таймингах рун'],
  recommendations: ['После файта — сразу башня/Рошан в течение 25 сек', 'Цель: 1.4 деварда / 10 мин', 'Драфтить более жадные кор-герои'],
  training_plan: ['Ластхит-дрилл 15 мин/день', 'Разбор 2 поражений в неделю', 'Вардинг по таймингам рун'],
  heroes_to_focus: ['Juggernaut', 'Anti-Mage', 'Morphling'],
  heroes_to_avoid: ['Faceless Void', 'Ember Spirit'],
  next_steps: ['Сыграть 5 ранкед на лучшем герое', 'Свериться с планом через неделю'],
}

const SECTIONS = [
  { key: 'strengths',       label: 'Сильные стороны', kind: 'good' },
  { key: 'weaknesses',      label: 'Слабые места',    kind: 'bad' },
  { key: 'main_mistakes',   label: 'Главные ошибки',  kind: 'bad' },
  { key: 'recommendations', label: 'Рекомендации',    kind: 'gold' },
  { key: 'training_plan',   label: 'План тренировок', kind: 'good' },
  { key: 'heroes_to_focus', label: 'Фокус-герои',     kind: 'good' },
  { key: 'heroes_to_avoid', label: 'Избегать',        kind: 'bad' },
  { key: 'next_steps',      label: 'Дальше',          kind: 'gold' },
]

function ListCard({ label, items, kind, accent }) {
  if (!items || !items.length) return null
  const color = kind === 'bad' ? GM.red : kind === 'gold' ? GM.premium : accent
  return (
    <Card pad={16}>
      <Kicker color={color} style={{ display: 'block', marginBottom: 10 }}>{label}</Kicker>
      <Stack gap={8}>
        {items.map((it, i) => (
          <div key={i} style={{ display: 'flex', alignItems: 'flex-start', gap: 9 }}>
            <span style={{ width: 6, height: 6, borderRadius: 999, background: color, marginTop: 6, flexShrink: 0 }} />
            <span style={{ fontSize: 13, color: GM.text, lineHeight: 1.5 }}>{it}</span>
          </div>
        ))}
      </Stack>
    </Card>
  )
}

function ReportView({ report, accent }) {
  return (
    <Card pad={20} glow accent={GM.premium} style={{ borderColor: `${GM.premium}33` }}>
      <SectionTitle
        title={<span style={{ display: 'flex', alignItems: 'center', gap: 8 }}><Icon name="spark" size={16} color={GM.premium} /> AI Report</span>}
        sub={report.created_at ? `Создан ${String(report.created_at).slice(0, 10)}` : 'Живой разбор'}
        right={<Badge color={GM.premium}>{report.demo ? 'DEMO' : 'LIVE'}</Badge>}
      />
      {report.summary && (
        <div style={{ background: GM.bg, border: `1px solid ${GM.border}`, borderRadius: 8, padding: 16, marginBottom: 14, fontSize: 13.5, lineHeight: 1.6, color: GM.text }}>
          {report.summary}
        </div>
      )}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: 12 }}>
        {SECTIONS.map(s => (
          <ListCard key={s.key} label={s.label} items={report[s.key]} kind={s.kind} accent={accent} />
        ))}
      </div>
    </Card>
  )
}

export default function AICoach({ game }) {
  const accent = game === 'cs2' ? CS2_ACCENT : DOTA_ACCENT
  const [accountId, setAccountId] = useState(profile.getDotaId() || '369102305')
  const [matchId, setMatchId] = useState('')
  const [busy, setBusy] = useState('')
  const [report, setReport] = useState(null)
  const [note, setNote] = useState('')

  const isCs = game === 'cs2'

  const runPlayerReview = async () => {
    setBusy('player'); setNote('')
    try {
      const r = await aiCoach.review(accountId.trim())
      setReport(r)
    } catch (err) {
      setNote(errNote(err))
      setReport(DEMO_REPORT)
    } finally { setBusy('') }
  }

  const runMatchReview = async () => {
    if (!matchId.trim()) return
    setBusy('match'); setNote('')
    try {
      const r = await aiCoach.reviewMatch(matchId.trim(), accountId.trim())
      setReport(r)
    } catch (err) {
      setNote(errNote(err))
      setReport(DEMO_REPORT)
    } finally { setBusy('') }
  }

  return (
    <Stack gap={16}>
      <Card glow accent={GM.premium} pad={24} style={{ borderColor: `${GM.premium}33` }}>
        <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', flexWrap: 'wrap', gap: 16 }}>
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 10 }}>
              <Icon name="spark" size={22} color={GM.premium} />
              <div style={{ fontSize: 22, fontWeight: 900 }}>AI Coach</div>
              <Badge color={GM.premium}>◆ PRO</Badge>
            </div>
            <div style={{ fontSize: 14, color: GM.muted, maxWidth: 520, lineHeight: 1.6 }}>
              Нейросеть анализирует профиль и матчи (OpenDota + Stratz), а разбор конкретной игры строится из распарсенного реплея — тимфайты, тайминги, лейн.
            </div>
          </div>
          <div style={{ background: `${GM.premium}16`, border: `1px solid ${GM.premium}44`, borderRadius: 8, padding: '12px 18px', textAlign: 'center' }}>
            <Mono style={{ fontSize: 11, color: GM.premium, display: 'block', marginBottom: 4 }}>БЕСПЛАТНО</Mono>
            <div style={{ fontSize: 22, fontWeight: 900, color: GM.premium }}>0 ₽</div>
            <div style={{ fontSize: 11, color: GM.muted }}>первый AI-прогон</div>
          </div>
        </div>

        {/* Player review */}
        <div style={{ marginTop: 20 }}>
          <Kicker style={{ display: 'block', marginBottom: 8 }}>Разбор игрока (последние ~100 матчей)</Kicker>
          <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap' }}>
            <InputBox value={accountId} onChange={setAccountId} placeholder="Dota account ID" />
            <ActionBtn onClick={runPlayerReview} busy={busy === 'player'} label="Разобрать профиль" />
          </div>
        </div>

        {/* Match review */}
        {!isCs && (
          <div style={{ marginTop: 16 }}>
            <Kicker style={{ display: 'block', marginBottom: 8 }}>Разбор матча (демка → текст → AI)</Kicker>
            <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap' }}>
              <InputBox value={matchId} onChange={setMatchId} placeholder="Match ID (напр. 7891234567)" mono />
              <ActionBtn onClick={runMatchReview} busy={busy === 'match'} label="Разобрать матч" />
            </div>
          </div>
        )}

        {note && <div style={{ marginTop: 12, fontSize: 12, color: GM.premium, fontFamily: "'JetBrains Mono', monospace" }}>{note}</div>}
      </Card>

      {/* How it works */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: 12 }}>
        {[['graph', '1. Данные', 'OpenDota + Stratz: форма, герои, лейн, варды'], ['cube', '2. Реплей', 'OpenDota парсит демку: тимфайты, тайминги'], ['spark', '3. AI Plan', 'Нейросеть превращает цифры в план роста']].map(([icon, title, sub]) => (
          <Card key={title} pad={18}>
            <Icon name={icon} size={20} color={GM.premium} />
            <div style={{ fontSize: 15, fontWeight: 800, margin: '10px 0 6px' }}>{title}</div>
            <div style={{ fontSize: 12.5, color: GM.muted, lineHeight: 1.5 }}>{sub}</div>
          </Card>
        ))}
      </div>

      {busy && (
        <Card pad={36} style={{ textAlign: 'center' }}>
          <div style={{ fontSize: 15, fontWeight: 700, marginBottom: 12, color: GM.premium }}>
            {busy === 'match' ? 'Парсю реплей и анализирую матч…' : 'Анализирую матчи…'}
          </div>
          <div style={{ width: '100%', height: 4, background: GM.surf, borderRadius: 999, overflow: 'hidden' }}>
            <div style={{ height: '100%', width: '70%', background: GM.premium, borderRadius: 999, animation: 'progress 2s linear infinite' }} />
          </div>
          <style>{`@keyframes progress { from { width: 5% } to { width: 95% } }`}</style>
        </Card>
      )}

      {report && !busy && <ReportView report={report} accent={accent} />}
    </Stack>
  )
}

function InputBox({ value, onChange, placeholder, mono }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', background: GM.bg, border: `1px solid ${GM.border}`, borderRadius: 8, padding: '0 14px', gap: 8, flex: '1 1 220px', maxWidth: 320 }}>
      <Icon name="search" size={15} color={GM.deep} />
      <input
        value={value}
        onChange={e => onChange(e.target.value)}
        placeholder={placeholder}
        style={{ flex: 1, background: 'none', border: 'none', outline: 'none', color: GM.text, fontSize: 14, padding: '12px 0', fontFamily: mono ? "'JetBrains Mono', monospace" : 'inherit' }}
      />
    </div>
  )
}

function ActionBtn({ onClick, busy, label }) {
  return (
    <button onClick={onClick} disabled={busy} style={{
      padding: '12px 22px', borderRadius: 8, border: 'none',
      background: busy ? GM.surf : GM.premium, color: GM.bg,
      fontWeight: 800, fontSize: 14, fontFamily: 'inherit',
      cursor: busy ? 'not-allowed' : 'pointer', display: 'flex', alignItems: 'center', gap: 8,
    }}>
      <Icon name="bolt" size={15} color={GM.bg} /> {busy ? 'Генерирую…' : label}
    </button>
  )
}

function errNote(err) {
  const m = (err && err.message) || 'ошибка'
  if (/provider_disabled|disabled/i.test(m)) return 'Нейросеть не подключена на бэке (AI_PROVIDER/AI_API_KEY/AI_MODEL) — показан демо-отчёт.'
  return `API недоступен (${m}) — показан демо-отчёт.`
}
