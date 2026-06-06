import { StrictMode, useState, useEffect } from 'react'
import { createRoot } from 'react-dom/client'
import {
  BrowserRouter, Routes, Route, Navigate, useLocation,
} from 'react-router-dom'

import { loadTheme, applyTheme } from './lib/theme.js'
import { AppShell } from './components/Shell.jsx'

import ProductSelect from './pages/ProductSelect.jsx'
import Register from './pages/Register.jsx'
import Profile from './pages/Profile.jsx'

import DotaDashboard from './pages/DotaDashboard.jsx'
import DotaPlayerAnalysis from './pages/DotaPlayerAnalysis.jsx'
import Heroes from './pages/Heroes.jsx'
import Training from './pages/Training.jsx'
import Meta from './pages/Meta.jsx'
import Subscription from './pages/Subscription.jsx'
import AICoach from './pages/AICoach.jsx'

import CS2Dashboard from './pages/CS2Dashboard.jsx'
import CS2Grenades from './pages/CS2Grenades.jsx'
import CS2Maps from './pages/CS2Maps.jsx'
import UtilitySets from './pages/UtilitySets.jsx'

// Persisted active product (dota | cs2)
function loadGame() {
  try { return localStorage.getItem('gm.game') || 'dota' } catch { return 'dota' }
}

function App() {
  const [game, setGameState] = useState(loadGame)
  const [theme, setThemeState] = useState(loadTheme)
  const location = useLocation()

  const setGame = (g) => {
    setGameState(g)
    try { localStorage.setItem('gm.game', g) } catch { /* ignore */ }
  }

  const setTheme = (t) => {
    applyTheme(t)
    setThemeState(t)
  }

  // Keep the active product in sync with the URL prefix
  useEffect(() => {
    if (location.pathname.startsWith('/cs2') && game !== 'cs2') setGame('cs2')
    else if (location.pathname.startsWith('/dota') && game !== 'dota') setGame('dota')
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [location.pathname])

  return (
    <AppShell game={game} setGame={setGame} theme={theme} setTheme={setTheme}>
      <Routes>
        <Route path="/" element={<Navigate to="/product-select" replace />} />
        <Route path="/product-select" element={<ProductSelect setGame={setGame} theme={theme} setTheme={setTheme} />} />
        <Route path="/register" element={<Register setGame={setGame} />} />
        <Route path="/profile" element={<Profile />} />

        {/* Dota 2 Lab */}
        <Route path="/dota" element={<DotaDashboard />} />
        <Route path="/dota/player/:id" element={<DotaPlayerAnalysis />} />
        <Route path="/dota/ai-coach" element={<AICoach game="dota" />} />
        <Route path="/dota/heroes" element={<Heroes game="dota" />} />
        <Route path="/dota/training" element={<Training game="dota" />} />
        <Route path="/dota/meta" element={<Meta game="dota" />} />
        <Route path="/dota/subscription" element={<Subscription game="dota" />} />

        {/* CS2 Lab */}
        <Route path="/cs2" element={<CS2Dashboard />} />
        <Route path="/cs2/maps" element={<CS2Maps />} />
        <Route path="/cs2/grenades" element={<CS2Grenades />} />
        <Route path="/cs2/training" element={<Training game="cs2" />} />
        <Route path="/cs2/sets" element={<UtilitySets />} />
        <Route path="/cs2/ai-coach" element={<AICoach game="cs2" />} />
        <Route path="/cs2/subscription" element={<Subscription game="cs2" />} />

        <Route path="*" element={<Navigate to="/product-select" replace />} />
      </Routes>
    </AppShell>
  )
}

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </StrictMode>,
)
