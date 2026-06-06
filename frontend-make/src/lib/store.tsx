import { createContext, useContext, useState, useRef, useEffect, ReactNode } from "react";
import { dota, identity } from "./api";
import { mapDashboard, PlayerData } from "./mapper";
import { useAuth } from "./auth";

const OFFSET = 76561197960265728;

interface PlayerState {
  data: PlayerData | null;
  loading: boolean;
  live: boolean;
  error: string;
  accountId: string;       // account id currently shown in the dashboard
  viewingSelf: boolean;    // true when showing the logged-in user's own account
  search: (input: string) => Promise<void>;
  resetToSelf: () => void;  // go back to the logged-in user's own stats
}

const Ctx = createContext<PlayerState | null>(null);

export function PlayerProvider({ children }: { children: ReactNode }) {
  const { user } = useAuth();
  const [state, setState] = useState<{
    data: PlayerData | null; loading: boolean; live: boolean; error: string; accountId: string; viewingSelf: boolean;
  }>({ data: null, loading: false, live: false, error: "", accountId: "", viewingSelf: true });

  // true once the user manually searched someone else (so we stop auto-loading self)
  const manualRef = useRef(false);

  async function loadById(accountId: string, self: boolean) {
    if (!accountId) return;
    setState((s) => ({ ...s, loading: true, error: "" }));
    try {
      const raw = await dota.getDashboard(accountId);
      setState({ data: mapDashboard(raw), loading: false, live: true, error: "", accountId, viewingSelf: self });
    } catch (e: any) {
      setState((s) => ({ ...s, loading: false, error: e?.message || "Не удалось загрузить профиль" }));
    }
  }

  async function search(input: string) {
    const q = (input || "").trim();
    if (!q) return;
    manualRef.current = true;
    setState((s) => ({ ...s, loading: true, error: "" }));
    try {
      let accountId = q;
      const numeric = /^[0-9]+$/.test(q);
      if (!numeric || Number(q) > OFFSET) {
        const r = await identity.resolveDota({ input: q });
        accountId = r.opendota_account_id || r.canonical_account_id;
      }
      try { localStorage.setItem("gm.dotaId", accountId); } catch { /* ignore */ }
      const selfId = user?.dota_account_id ? String(user.dota_account_id) : "";
      await loadById(accountId, selfId !== "" && accountId === selfId);
    } catch (e: any) {
      setState((s) => ({ ...s, loading: false, error: e?.message || "Не удалось загрузить профиль" }));
    }
  }

  function resetToSelf() {
    manualRef.current = false;
    if (user?.dota_account_id) loadById(String(user.dota_account_id), true);
  }

  // Auto-load the logged-in user's own account when they have one linked,
  // as long as they are not currently viewing someone else from a search.
  const linkedId = user?.dota_account_id ? String(user.dota_account_id) : "";
  useEffect(() => {
    if (manualRef.current) return;
    if (linkedId && linkedId !== state.accountId) {
      loadById(linkedId, true);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [linkedId]);

  return (
    <Ctx.Provider value={{ ...state, search, resetToSelf }}>{children}</Ctx.Provider>
  );
}

export function usePlayer(): PlayerState {
  const ctx = useContext(Ctx);
  if (!ctx) throw new Error("usePlayer must be used within PlayerProvider");
  return ctx;
}
