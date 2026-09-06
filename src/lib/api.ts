import type {
  DashboardFarm,
  FarmRecord,
  ModelMetrics,
  PredictionRecord,
  WeatherData,
} from "../types";

/**
 * AeroYield backend API client.
 *
 * Env vars (set in Vercel dashboard for production, or in a .env file locally):
 *   VITE_API_URL  — backend base URL (defaults to the Render deployment)
 *   VITE_API_KEY  — X-API-Key value (defaults to the production key)
 *
 * Every call falls back to local mock data when the backend is unreachable,
 * so the dashboard stays fully functional in demo mode.
 */
const API_BASE: string =
  (import.meta.env.VITE_API_URL as string | undefined) ??
  (import.meta.env.VITE_API_BASE_URL as string | undefined) ??
  "https://aeroyield-api.onrender.com";

const API_KEY: string =
  (import.meta.env.VITE_API_KEY as string | undefined) ??
  "aeroyield-8iUXOUZIBl0YDT2uKh4WHAYoHXRPWsAhidkT";

/** Default headers shared across every API call (CORS preflight passes on these). */
const baseHeaders: Record<string, string> = {
  Accept: "application/json",
  "X-API-Key": API_KEY,
};

/**
 * Render free-tier cold starts take 30–60s, so we give fetch a generous
 * 60-second window. Falls back to mock data on any network/timeout failure.
 */
async function getJson<T>(path: string, timeoutMs = 60000): Promise<T | null> {
  try {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), timeoutMs);
    const res = await fetch(`${API_BASE}${path}`, {
      signal: controller.signal,
      headers: baseHeaders,
    });
    clearTimeout(timer);
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    return (await res.json()) as T;
  } catch {
    return null;
  }
}

export const api = {
  /** GET /api/farms — base farm list (used by map, table, KPIs) */
  getFarms: () => getJson<FarmRecord[]>("/api/farms"),

  /** GET /api/admin/dashboard */
  getDashboard: () => getJson<DashboardFarm[]>("/api/admin/dashboard"),

  /** GET /api/admin/predictions */
  getPredictions: () => getJson<PredictionRecord[]>("/api/admin/predictions"),

  /** GET /api/admin/model-metrics */
  getModelMetrics: () => getJson<ModelMetrics>("/api/admin/model-metrics"),

  /** GET /api/farms/{id} → weather object */
  getFarmWeather: (fieldId: string) =>
    getJson<WeatherData>(`/api/farms/${fieldId}`),

  /** POST /api/predict/{field_id} — re-run ML model with current weather */
  async triggerPrediction(
    fieldId: string,
    weather: WeatherData
  ): Promise<{ ok: boolean; data?: unknown }> {
    try {
      const controller = new AbortController();
      const timer = setTimeout(() => controller.abort(), 60000);
      const res = await fetch(`${API_BASE}/api/predict/${fieldId}`, {
        method: "POST",
        headers: { ...baseHeaders, "Content-Type": "application/json" },
        body: JSON.stringify(weather),
        signal: controller.signal,
      });
      clearTimeout(timer);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      return { ok: true, data: await res.json() };
    } catch {
      return { ok: false };
    }
  },
};

export { API_BASE };
