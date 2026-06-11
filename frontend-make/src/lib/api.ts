// GameMentor API client — matches the Go backend (internal/delivery/http/router.go)
// In local/Docker the frontend is proxied, so the relative "/api/v1" works.
// For GitHub Pages (no proxy) set VITE_API_BASE_URL to the deployed backend,
// e.g. https://gamementor-api.onrender.com/api/v1
const BASE = (import.meta as any).env?.VITE_API_BASE_URL || "/api/v1";
const TOKEN_KEY = "gm.token";

// --- auth token storage (localStorage) ---
export function getToken(): string {
  try { return localStorage.getItem(TOKEN_KEY) || ""; } catch { return ""; }
}
export function setToken(token: string) {
  try { token ? localStorage.setItem(TOKEN_KEY, token) : localStorage.removeItem(TOKEN_KEY); } catch { /* ignore */ }
}
export function clearToken() { setToken(""); }

async function request(path: string, opts: RequestInit = {}): Promise<any> {
  const token = getToken();
  const res = await fetch(BASE + path, {
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: "Bearer " + token } : {}),
      ...(opts.headers || {}),
    },
    ...opts,
  });
  let json: any;
  try { json = await res.json(); } catch { throw new Error("HTTP " + res.status); }
  if (!res.ok || json.success === false) {
    const err: any = new Error(json?.error?.message || "HTTP " + res.status);
    err.status = res.status;
    err.code = json?.error?.code;
    throw err;
  }
  return json.data;
}

export const API_BASE = BASE;

// rawRequest performs ONE fetch and returns status/time/body WITHOUT unwrapping
// .data — used by the API test page so every call shows up in the Network tab.
export async function rawRequest(path: string, opts: RequestInit = {}): Promise<{ status: number; ok: boolean; ms: number; body: any }> {
  const token = getToken();
  const t0 = (typeof performance !== "undefined" ? performance.now() : Date.now());
  const res = await fetch(BASE + path, {
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: "Bearer " + token } : {}),
      ...(opts.headers || {}),
    },
    ...opts,
  });
  const ms = Math.round((typeof performance !== "undefined" ? performance.now() : Date.now()) - t0);
  let body: any;
  try { body = await res.json(); } catch { body = { _note: "non-JSON response" }; }
  return { status: res.status, ok: res.ok, ms, body };
}

const qs = (params: Record<string, any> = {}) => {
  const q = new URLSearchParams(params as any).toString();
  return q ? "?" + q : "";
};

export const auth = {
  register: (body: any) => request("/auth/register", { method: "POST", body: JSON.stringify(body) }),
  login: (body: any) => request("/auth/login", { method: "POST", body: JSON.stringify(body) }),
  me: () => request("/auth/me"),
};

export const users = {
  getProfile: (id: string) => request(`/users/${id}/profile`),
  updateProfile: (id: string, body: any) => request(`/users/${id}/profile`, { method: "PUT", body: JSON.stringify(body) }),
  getMe: () => request("/users/me/profile"),
  updateMe: (body: any) => request("/users/me/profile", { method: "PUT", body: JSON.stringify(body) }),
};

export const billing = {
  plans: () => request("/billing/plans"),
  subscription: () => request("/billing/subscription"),
  subscribe: (plan: string) => request("/billing/subscribe", { method: "POST", body: JSON.stringify({ plan }) }),
  cancel: () => request("/billing/cancel", { method: "POST" }),
};

export const dota = {
  profile: (steamId: string) => request(`/dota/player/${steamId}/profile`),
  getDashboard: (steamId: string, params: Record<string, any> = {}) => request(`/dota/lab/players/${steamId}/dashboard${qs(params)}`),
  getProComparison: (steamId: string, params: Record<string, any> = {}) => request(`/dota/lab/players/${steamId}/pro-comparison${qs(params)}`),
  getHeroes: (steamId: string, params: Record<string, any> = {}) => request(`/dota/lab/players/${steamId}/heroes${qs(params)}`),
  getForm: (steamId: string) => request(`/dota/lab/players/${steamId}/form`),
  getWeaknesses: (steamId: string) => request(`/dota/lab/players/${steamId}/weaknesses`),
  getAICoachPreview: (steamId: string) => request(`/dota/lab/players/${steamId}/ai-coach-preview`),
  refresh: (steamId: string, params: Record<string, any> = {}) => request(`/dota/lab/players/${steamId}/refresh${qs(params)}`, { method: "POST" }),
  explore: (steamId: string) => request(`/dota/explorer/${steamId}`),
  metrics: (steamId: string, params: Record<string, any> = {}) => request(`/dota/metrics/${steamId}${qs(params)}`),
  rawMatches: (steamId: string, limit = 15) => request(`/dota/raw/${steamId}/matches?limit=${limit}`),
};

export const identity = {
  resolveDota: (body: any) => request("/identity/dota/resolve", { method: "POST", body: JSON.stringify(body) }),
};

export const aiCoach = {
  review: (steamId: string, focus = "") => request(`/ai-coach/dota/player/${steamId}/review`, { method: "POST", body: JSON.stringify({ focus }) }),
  latest: (steamId: string) => request(`/ai-coach/dota/player/${steamId}/latest`),
  reviewMatch: (matchId: string, steamId = "") => request(`/ai-coach/dota/match/${matchId}/review${steamId ? "?steam_id=" + encodeURIComponent(steamId) : ""}`, { method: "POST" }),
  getReport: (reportId: string) => request(`/ai-coach/dota/reports/${reportId}`),
};

export const cs2 = {
  getMaps: () => request("/cs2/maps"),
  getGrenades: (params: Record<string, any> = {}) => request(`/cs2/grenades${qs(params)}`),
  getGrenade: (id: string) => request(`/cs2/grenades/${id}`),
  createGrenade: (body: any) => request("/cs2/grenades", { method: "POST", body: JSON.stringify(body) }),
};
