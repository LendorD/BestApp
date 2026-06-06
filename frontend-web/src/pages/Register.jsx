import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { GM, DOTA_ACCENT, CS2_ACCENT } from '../lib/theme.js'
import { Card, Kicker, Icon, Mono, Stack } from '../components/primitives.jsx'
import { auth } from '../lib/api.js'
import { profile } from '../lib/storage.js'

export default function Register() {
  const nav = useNavigate()
  const accent = DOTA_ACCENT
  const [mode, setMode] = useState('register') // register | login
  const [form, setForm] = useState({ name: '', email: '', password: '' })
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState('')

  const upd = (k) => (e) => setForm(f => ({ ...f, [k]: e.target.value }))

  const submit = async () => {
    setBusy(true); setError('')
    try {
      const body = mode === 'register'
        ? { name: form.name, email: form.email, password: form.password }
        : { email: form.email, password: form.password }
      await (mode === 'register' ? auth.register(body) : auth.login(body))
      if (form.name) profile.setName(form.name)
      nav('/product-select')
    } catch (err) {
      // Backend may be offline — let the user continue in demo mode
      setError(`${err.message}. Можно продолжить в демо-режиме.`)
    } finally {
      setBusy(false)
    }
  }

  return (
    <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 24, position: 'relative' }}>
      <div style={{ position: 'fixed', inset: 0, backgroundImage: `linear-gradient(${GM.border}55 1px, transparent 1px), linear-gradient(90deg, ${GM.border}55 1px, transparent 1px)`, backgroundSize: '56px 56px', opacity: 0.3, pointerEvents: 'none' }} />
      <div style={{ position: 'relative', zIndex: 1, width: '100%', maxWidth: 420 }}>
        <div style={{ textAlign: 'center', marginBottom: 28 }}>
          <div style={{ display: 'inline-flex', alignItems: 'center', gap: 12, marginBottom: 10 }}>
            <div style={{ width: 44, height: 44, borderRadius: 10, background: GM.card, border: `1px solid ${accent}`, display: 'flex', alignItems: 'center', justifyContent: 'center', color: accent, fontWeight: 900, fontSize: 22 }}>G</div>
            <div style={{ fontSize: 26, fontWeight: 900, letterSpacing: '-0.03em' }}>GameMentor</div>
          </div>
          <div style={{ fontSize: 14, color: GM.muted }}>Премиум аналитика для Dota 2 и CS2</div>
        </div>

        <Card pad={24}>
          <div style={{ display: 'flex', gap: 4, padding: 3, background: GM.bg, border: `1px solid ${GM.border}`, borderRadius: 8, marginBottom: 18 }}>
            {[['register', 'Регистрация'], ['login', 'Вход']].map(([m, lbl]) => (
              <button key={m} onClick={() => setMode(m)} style={{
                flex: 1, border: 'none', cursor: 'pointer', padding: '9px 0', borderRadius: 6,
                fontWeight: 800, fontSize: 13, fontFamily: 'inherit',
                background: mode === m ? accent : 'transparent', color: mode === m ? GM.bg : GM.muted,
              }}>{lbl}</button>
            ))}
          </div>

          <Stack gap={12}>
            {mode === 'register' && (
              <input value={form.name} onChange={upd('name')} placeholder="Имя" style={inputStyle} />
            )}
            <input value={form.email} onChange={upd('email')} type="email" placeholder="Email" style={inputStyle} />
            <input value={form.password} onChange={upd('password')} type="password" placeholder="Пароль" style={inputStyle} />

            {error && <div style={{ fontSize: 12, color: GM.red, lineHeight: 1.5 }}>{error}</div>}

            <button onClick={submit} disabled={busy} style={{
              padding: '13px 0', borderRadius: 8, border: 'none',
              background: busy ? GM.surf : accent, color: GM.bg, fontWeight: 800, fontSize: 14,
              fontFamily: 'inherit', cursor: busy ? 'not-allowed' : 'pointer',
              display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
            }}>
              {busy ? 'Подождите…' : (mode === 'register' ? 'Создать аккаунт' : 'Войти')}
            </button>

            <button onClick={() => nav('/product-select')} style={{
              padding: '11px 0', borderRadius: 8, border: `1px solid ${GM.border}`,
              background: 'transparent', color: GM.muted, fontWeight: 700, fontSize: 13,
              fontFamily: 'inherit', cursor: 'pointer',
            }}>
              Продолжить в демо-режиме →
            </button>
          </Stack>
        </Card>
      </div>
    </div>
  )
}

const inputStyle = {
  width: '100%', background: GM.surf, border: `1px solid ${GM.border}`,
  borderRadius: 8, padding: '12px 14px', color: GM.text, fontSize: 14,
  fontFamily: 'inherit', outline: 'none',
}
