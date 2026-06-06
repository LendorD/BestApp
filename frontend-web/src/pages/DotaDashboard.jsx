import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { GM, DOTA_ACCENT } from '../lib/theme.js'
import { Card, Kicker, Badge, Icon, Mono, Stack } from '../components/primitives.jsx'
import { ProfileHeader, ScorePanel, KpiGrid, TrendCard, RadarCard } from '../components/blocks.jsx'
import { MOCK_DOTA } from '../lib/mockData.js'
import { profile } from '../lib/storage.js'
import { identity } from '../lib/api.js'

export default function DotaDashboard() {
  const nav = useNavigate()
  const [accountId, setAccountId] = useState(profile.getDotaId() || '369102305')
  const [period, setPeriod] = useState('30D')
  const [resolving, setResolving] = useState(false)
  const [resolveErr, setResolveErr] = useState('')
  const accent = DOTA_ACCENT
  const d = { ...MOCK_DOTA, accent }

  const handleAnalyze = async () => {
    const input = accountId.trim()
    if (!input || resolving) return
    setResolving(true)
    setResolveErr('')
    try {
      const res = await identity.resolveDota({ input })
      const aid = res.opendota_account_id || res.canonical_account_id
      profile.setDotaId(aid)
      nav(`/dota/player/${aid}`)
    } catch (e) {
      if (/^[0-9]+$/.test(input)) {
        nav(`/dota/player/${input}`)
      } else {
        setResolveErr(e.message || 'Не удалось распознать профиль. Для ссылок /id/ нужен STEAM_API_KEY.')
      }
    } finally {
      setResolving(false)
    }
  }

  return (
    <Stack gap={16}>
      {/* Hero search card */}
      <Card glow accent={accent} pad={0} style={{ borderColor: `${accent}3a`, overflow: 'hidden' }}>
        <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(90deg, rgba(5,6,8,0.96) 60%, rgba(0,208,132,0.06) 100%)', pointerEvents: 'none' }} />
        <div style={{ position: 'relative', padding: 28 }}>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8, marginBottom: 16 }}>
            <Badge color={accent}><Icon name="graph" size={12} /> Dota Lab</Badge>
            <Badge color={GM.premium}>◆ первый AI-прогон за 0 ₽</Badge>
          </div>
          <div style={{ fontSize: 26, fontWeight: 900, letterSpacing: '-0.02em', lineHeight: 1.1, maxWidth: 520, marginBottom: 10 }}>
            Разбор профиля, который сразу показывает, куда теряется рейтинг
          </div>
          <div style={{ fontSize: 14, color: GM.muted, maxWidth: 520, marginBottom: 22, lineHeight: 1.6 }}>
            Вставь ссылку Steam, SteamID64 или Dota account ID — GameMentor соберёт матчи OpenDota, покажет форму, героев, сравнение с pro и план AI Coach.
          </div>
          <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap' }}>
            <div style={{ display: 'flex', alignItems: 'center', background: GM.surf, border: `1px solid ${GM.border}`, borderRadius: 8, padding: '0 14px', gap: 8, flex: '1 1 260px', maxWidth: 440 }}>
              <Icon name="search" size={15} color={GM.deep} />
              <input
                value={accountId}
                onChange={e => setAccountId(e.target.value)}
                onKeyDown={e => e.key === 'Enter' && handleAnalyze()}
                placeholder="Steam-ссылка, SteamID64 или Dota ID"
                style={{
                  flex: 1, background: 'none', border: 'none', outline: 'none',
                  color: GM.text, fontSize: 14, fontFamily: 'inherit', padding: '12px 0',
                }}
              />
            </div>
            <button onClick={handleAnalyze} disabled={resolving} style={{
              padding: '12px 24px', borderRadius: 8, border: 'none',
              background: resolving ? GM.surf : accent, color: GM.bg, fontWeight: 800, fontSize: 14,
              fontFamily: 'inherit', cursor: resolving ? 'not-allowed' : 'pointer', display: 'flex', alignItems: 'center', gap: 8,
            }}>
              <Icon name="graph" size={15} color={GM.bg} /> {resolving ? 'Ищу…' : 'Анализировать'}
            </button>
          </div>
          {resolveErr ? <div style={{ marginTop: 10, fontSize: 12.5, color: GM.red }}>{resolveErr}</div> : null}
          {/* Preview features */}
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(160px, 1fr))', gap: 10, marginTop: 22 }}>
            {[['trophy', 'GameMentor Score', '0-100'], ['cube', 'Hero Pool', 'лучшие/слабые'], ['graph', 'Pro Compare', 'Yatoro/Nisha/RTZ'], ['spark', 'AI Coach', 'план роста']].map(([icon, title, sub]) => (
              <div key={title} style={{ background: GM.card, border: `1px solid ${GM.border}`, borderRadius: 8, padding: '12px 14px', display: 'flex', alignItems: 'center', gap: 10 }}>
                <Icon name={icon} size={18} color={accent} />
                <div>
                  <div style={{ fontSize: 13, fontWeight: 800 }}>{title}</div>
                  <div style={{ fontSize: 11, color: GM.muted }}>{sub}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </Card>

      {/* Metrics */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(140px, 1fr))', gap: 12 }}>
        {[['8', 'ключевых графиков'], ['100', 'матчей в срезе'], ['7/30/90', 'периоды анализа'], ['0 ₽', 'первый AI-тест']].map(([v, l]) => (
          <Card key={l} pad={16}>
            <div style={{ fontSize: 26, fontWeight: 900, letterSpacing: '-0.02em' }}>{v}</div>
            <div style={{ fontSize: 12, color: GM.muted, marginTop: 4 }}>{l}</div>
          </Card>
        ))}
      </div>

      {/* Sample dashboard (demo preview) */}
      <div style={{ position: 'relative' }}>
        <div style={{ position: 'absolute', inset: 0, zIndex: 10, display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'rgba(5,6,8,0.7)', borderRadius: 8, backdropFilter: 'blur(2px)' }}>
          <div style={{ textAlign: 'center', padding: 32 }}>
            <div style={{ fontSize: 18, fontWeight: 800, marginBottom: 10 }}>Введи профиль для реального дашборда</div>
            <Mono style={{ fontSize: 12, color: GM.muted }}>Ниже — демо-данные</Mono>
          </div>
        </div>
        <Stack gap={16}>
          <ProfileHeader d={d} accent={accent} period={period} setPeriod={setPeriod} />
          <div style={{ display: 'grid', gridTemplateColumns: '5fr 7fr', gap: 16 }}>
            <ScorePanel d={d} accent={accent} />
            <KpiGrid d={d} accent={accent} cols={3} />
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '7fr 5fr', gap: 16 }}>
            <TrendCard d={d} accent={accent} />
            <RadarCard d={d} accent={accent} />
          </div>
        </Stack>
      </div>
    </Stack>
  )
}
