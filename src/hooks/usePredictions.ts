import { useState, useEffect, useCallback, useMemo } from "react";
import { api } from "../lib/api";
import {
  dashboardFarms as mockDashboardFarms,
  predictionHistory as mockHistory,
  modelMetrics as mockMetrics,
  scoreToClass,
} from "../data/mockAdminData";
import type {
  DashboardFarm,
  ModelMetrics,
  PredictionRecord,
  RegionFilter,
} from "../types";

/**
 * Loads ML prediction data from the backend (port 8000) and falls back to
 * local mock data. Also exposes the manual "re-run model" action which
 * POSTs to /api/predict/{field_id}.
 */
export function usePredictions() {
  const [farms, setFarms] = useState<DashboardFarm[]>(mockDashboardFarms);
  const [history, setHistory] = useState<PredictionRecord[]>(mockHistory);
  const [metrics, setMetrics] = useState<ModelMetrics | null>(mockMetrics);
  const [loading, setLoading] = useState(true);
  const [live, setLive] = useState(false);
  const [runningIds, setRunningIds] = useState<Set<string>>(new Set());
  const [toast, setToast] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      const [dash, preds, mets] = await Promise.all([
        api.getDashboard(),
        api.getPredictions(),
        api.getModelMetrics(),
      ]);
      if (cancelled) return;
      const anyLive = dash !== null || preds !== null || mets !== null;
      setLive(anyLive);
      if (dash) setFarms(dash);
      if (preds) setHistory(preds);
      if (mets) setMetrics(mets);
      setLoading(false);
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  const showToast = useCallback((msg: string) => {
    setToast(msg);
    setTimeout(() => setToast(null), 3200);
  }, []);

  /** POST /api/predict/{field_id} — re-run ML model for one farm */
  const triggerPrediction = useCallback(
    async (fieldId: string) => {
      const farm = farms.find((f) => f.field_id === fieldId);
      if (!farm || runningIds.has(fieldId)) return;

      setRunningIds((prev) => new Set(prev).add(fieldId));
      const result = await api.triggerPrediction(fieldId, farm.weather);

      // Simulated result when the backend is offline (demo mode)
      const newScore = result.ok
        ? (farm.crop_vital_score as number)
        : Math.max(
            5,
            Math.min(100, farm.crop_vital_score + Math.round((Math.random() - 0.5) * 12))
          );
      const newConfidence = parseFloat((0.82 + Math.random() * 0.15).toFixed(2));
      const now = new Date().toISOString();

      setFarms((prev) =>
        prev.map((f) =>
          f.field_id === fieldId
            ? {
                ...f,
                crop_vital_score: newScore,
                prediction_class: scoreToClass(newScore),
                confidence: newConfidence,
                last_prediction_at: now,
              }
            : f
        )
      );
      setHistory((prev) => [
        {
          prediction_id: `pred_${Date.now()}`,
          field_id: fieldId,
          farmer_name: farm.farmer_name,
          district: farm.district,
          crop_type: farm.crop_type,
          crop_vital_score: newScore,
          prediction_class: scoreToClass(newScore),
          confidence: newConfidence,
          model_version: farm.model_version,
          timestamp: now,
          trigger: "manual",
          weather_inputs: {
            temperature_c: farm.weather.temperature_c,
            humidity_pct: farm.weather.humidity_pct,
            precipitation_mm: farm.weather.precipitation_mm,
          },
        },
        ...prev,
      ]);
      setRunningIds((prev) => {
        const next = new Set(prev);
        next.delete(fieldId);
        return next;
      });
      showToast(
        `${fieldId}: model re-run → vital score ${newScore} (${newConfidence * 100}% confidence)${
          result.ok ? "" : " · demo mode"
        }`
      );
    },
    [farms, runningIds, showToast]
  );

  const filteredFarms = useCallback(
    (region: RegionFilter, district: string) =>
      farms.filter((f) => {
        const regionMatch = region === "all" || f.region === region;
        const districtMatch = district === "All Districts" || f.district === district;
        return regionMatch && districtMatch;
      }),
    [farms]
  );

  return {
    farms,
    history,
    metrics,
    loading,
    live,
    runningIds,
    toast,
    triggerPrediction,
    filteredFarms,
  };
}
