import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { GM, DOTA_ACCENT } from '../lib/theme.js'
import { Card, Kicker, Badge, Icon, Mono, Stack, SectionTitle, Avatar } from '../components/primitives.jsx'
import { profile } from '../lib/storage.js'

export default function Profile() {
  const nav = useNavigate()
  const accent = DOTA_ACCENT
  const [name, setName] = useState(profile.getName())
  const [dotaId, setDotaId] = useState(profile.getDotaId())
  const [saved, setSaved] = useState(false)

  const save = () => {
    profile.setName(name.trim())
    profile.setDotaId(dotaId.trim())
    setSaved(true)
    setTimeout(() => setSaved(false), 1800)
  }

  return (
    <Stack gap={16} style={{ maxWidth: 760 }}>
      <Card glow accent={accent} pad={24} style={{ borderColor: `${accent}3a` }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 18 }}>
          <Avatar letter={(name || 'U')[0].toUpperCase()} accent={accent} size={68} />
          <div>
            <Kicker color={accent}>МОЙ ПРОФИЛЬ</Kicker>
            <div style={{ fontSize: 24, fontWeight: 900, letterSpacing: '-0.02em', marginTop: 4 }}>
              {name || 'Игрок GameMentor'}
            </div>
            <div style={{ fontSize: 13, color: GM.muted, marginTop: 4 }}>
              {dotaId ? <>Dota ID: <Mono style={{ color: GM.text }}>{dotaId}</Mono></> : 'Dota ID не задан'}
            </div>
          </div>
        </div>
      </Card>

      <Card pad={22}>
        <SectionTitle title="Настройки" sub="Сохраняются локально и используются для дашборда" />
        <Stack gap={16}>
          <Field label="Отображаемое имя">
            <input
              value={name}
              onChange={e => setName(e.target.value)}
              placeholder="Например, Lendor"
              style={inputStyle}
            />
          </Field>
          <Field label="Dota account ID" hint="32-битный Steam ID из OpenDota">
            <input
              value={dotaId}
              onChange={e => setDotaId(e.target.value.replace(/[^0-9]/g, ''))}
              placeholder="369102305"
              style={{ ...inputStyle, fontFamily: "'JetBrains Mono', monospace" }}
            />
          </Field>

          <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap' }}>
            <button onClick={save} style={{
              padding: '12px 24px', borderRadius: 8, border: 'none',
              background: accent, color: GM.bg, fontWeight: 800, fontSize: 14,
              fontFamily: 'inherit', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 8,
            }}>
              <Icon name="check" size={15} color={GM.bg} /> Сохранить
            </button>
            {dotaId && (
              <button onClick={() => nav(`/dota/player/${dotaId}`)} style={{
                padding: '12px 24px', borderRadius: 8, border: `1px solid ${accent}`,
                background: `${accent}16`, color: accent, fontWeight: 800, fontSize: 14,
                fontFamily: 'inherit', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 8,
              }}>
                <Icon name="graph" size={15} color={accent} /> Открыть мой дашборд
              </button>
            )}
            {saved && <Badge color={accent}>✓ Сохранено</Badge>}
          </div>
        </Stack>
      </Card>

      <Card pad={22}>
        <SectionTitle title="Подписка" sub="Текущий план" />
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: 12 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <Badge color={GM.premium}>◆ FREE</Badge>
            <span style={{ fontSize: 13, color: GM.muted }}>Первый AI-прогон бесплатно</span>
          </div>
          <button onClick={() => nav('/dota/subscription')} style={{
            padding: '10px 18px', borderRadius: 7, border: `1px solid ${GM.premium}`,
            background: `${GM.premium}16`, color: GM.premium, fontWeight: 800, fontSize: 13,
            fontFamily: 'inherit', cursor: 'pointer',
          }}>
            Улучшить до PRO
          </button>
        </div>
      </Card>
    </Stack>
  )
}

const inputStyle = {
  width: '100%', background: GM.surf, border: `1px solid ${GM.border}`,
  borderRadius: 8, padding: '12px 14px', color: GM.text, fontSize: 14,
  fontFamily: 'inherit', outline: 'none',
}

function Field({ label, hint, children }) {
  return (
    <div>
      <Kicker style={{ display: 'block', marginBottom: 8 }}>{label}</Kicker>
      {children}
      {hint && <div style={{ fontSize: 11.5, color: GM.deep, marginTop: 6 }}>{hint}</div>}
    </div>
  )
}
