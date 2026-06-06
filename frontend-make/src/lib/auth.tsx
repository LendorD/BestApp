import { createContext, useContext, useEffect, useState, ReactNode, useCallback } from "react";
import { auth, users, billing, getToken, setToken, clearToken } from "./api";

export interface User {
  id: number;
  email: string;
  username: string;
  display_name: string;
  avatar_url?: string;
  bio?: string;
  favorite_game?: string;
  dota_account_id?: number;
  created_at?: string;
  last_login_at?: string;
}

export interface Subscription {
  user_id: number;
  plan: string;
  status: string;
  current_period_end?: string;
}

interface AuthState {
  user: User | null;
  subscription: Subscription | null;
  loading: boolean;        // initial bootstrap
  ready: boolean;          // bootstrap finished
  login: (identity: string, password: string) => Promise<void>;
  register: (body: { email: string; username: string; password: string; display_name?: string }) => Promise<void>;
  logout: () => void;
  updateProfile: (body: Partial<User>) => Promise<User>;
  refresh: () => Promise<void>;
  subscribe: (plan: string) => Promise<void>;
  cancelSubscription: () => Promise<void>;
}

const Ctx = createContext<AuthState | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [subscription, setSubscription] = useState<Subscription | null>(null);
  const [loading, setLoading] = useState(true);
  const [ready, setReady] = useState(false);

  const loadSubscription = useCallback(async () => {
    try { setSubscription(await billing.subscription()); } catch { setSubscription(null); }
  }, []);

  const bootstrap = useCallback(async () => {
    if (!getToken()) { setLoading(false); setReady(true); return; }
    try {
      const me = await auth.me();
      setUser(me);
      await loadSubscription();
    } catch {
      clearToken();
      setUser(null);
    } finally {
      setLoading(false);
      setReady(true);
    }
  }, [loadSubscription]);

  useEffect(() => { bootstrap(); }, [bootstrap]);

  const afterAuth = useCallback(async (res: any) => {
    setToken(res.token);
    setUser(res.user);
    await loadSubscription();
  }, [loadSubscription]);

  const login = useCallback(async (identity: string, password: string) => {
    await afterAuth(await auth.login({ identity, password }));
  }, [afterAuth]);

  const register = useCallback(async (body: { email: string; username: string; password: string; display_name?: string }) => {
    await afterAuth(await auth.register(body));
  }, [afterAuth]);

  const logout = useCallback(() => {
    clearToken();
    setUser(null);
    setSubscription(null);
  }, []);

  const updateProfile = useCallback(async (body: Partial<User>) => {
    const updated = await users.updateMe({
      display_name: body.display_name ?? user?.display_name ?? "",
      avatar_url: body.avatar_url ?? user?.avatar_url ?? "",
      bio: body.bio ?? user?.bio ?? "",
      favorite_game: body.favorite_game ?? user?.favorite_game ?? "",
      dota_account_id: body.dota_account_id ?? user?.dota_account_id ?? null,
    });
    setUser(updated);
    return updated;
  }, [user]);

  const refresh = useCallback(async () => {
    if (!getToken()) return;
    try { setUser(await auth.me()); await loadSubscription(); } catch { /* ignore */ }
  }, [loadSubscription]);

  const subscribe = useCallback(async (plan: string) => {
    setSubscription(await billing.subscribe(plan));
  }, []);

  const cancelSubscription = useCallback(async () => {
    setSubscription(await billing.cancel());
  }, []);

  return (
    <Ctx.Provider value={{ user, subscription, loading, ready, login, register, logout, updateProfile, refresh, subscribe, cancelSubscription }}>
      {children}
    </Ctx.Provider>
  );
}

export function useAuth(): AuthState {
  const ctx = useContext(Ctx);
  if (!ctx) throw new Error("useAuth must be used within AuthProvider");
  return ctx;
}
