import { useState, useMemo } from "react";
import { History, Zap, CalendarClock } from "lucide-react";
import type { PredictionRecord } from "../types";
import { classLabel } from "../types";
import { cn } from "../lib/utils";
import { DisclaimerBanner } from "./DisclaimerBanner";

interface PredictionHistoryProps {
  history: PredictionRecord[];
}

const classStyles = {
  0: "bg-emerald-500/10 text-emerald-500 border-emerald-500/30",
  1: "bg-amber-500/10 text-amber-500 border-amber-500/30",
  2: "bg-red-500/10 text-red-500 border-red-500/30",
} as const;

function formatTime(iso: string) {
  const d = new Date(iso);
  return d.toLocaleString("en-PK", {
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

export function PredictionHistory({ history }: PredictionHistoryProps) {
  const [classFilter, setClassFilter] = useState<string>("all");

  const filtered = useMemo(
    () =>
      history.filter(
        (p) => classFilter === "all" || p.prediction_class === Number(classFilter)
      ),
    [history, classFilter]
  );

  return (
    <div className="space-y-6">
      <DisclaimerBanner />

      <div className="rounded-xl border border-border bg-card overflow-hidden">
        <div className="flex flex-wrap items-center gap-2 border-b border-border p-4">
          <History className="h-5 w-5 text-primary" />
          <h3 className="font-semibold text-foreground">Prediction History</h3>
          <span className="text-xs text-muted-foreground">
            GET /api/admin/predictions
          </span>
          <select
            value={classFilter}
            onChange={(e) => setClassFilter(e.target.value)}
            className="ml-auto rounded-lg border border-input bg-background px-3 py-1.5 text-sm text-foreground focus:outline-none focus:ring-2 focus:ring-ring"
          >
            <option value="all">All Classes</option>
            <option value="0">0 · Healthy</option>
            <option value="1">1 · Moderate</option>
            <option value="2">2 · Critical</option>
          </select>
        </div>

        <div className="p-4">
          {/* Timeline */}
          <ol className="relative border-l-2 border-border ml-3 space-y-4">
            {filtered.map((p) => (
              <li key={p.prediction_id} className="ml-6">
                <span
                  className={cn(
                    "absolute -left-[9px] mt-1.5 h-4 w-4 rounded-full border-2",
                    p.prediction_class === 0 && "bg-emerald-500 border-emerald-500/40",
                    p.prediction_class === 1 && "bg-amber-500 border-amber-500/40",
                    p.prediction_class === 2 && "bg-red-500 border-red-500/40"
                  )}
                />
                <div className="rounded-lg border border-border bg-background p-3">
                  <div className="flex flex-wrap items-center gap-2">
                    <p className="text-sm font-medium text-foreground">
                      {p.farmer_name}
                      <span className="ml-2 font-mono text-xs text-muted-foreground">
                        {p.field_id}
                      </span>
                    </p>
                    <span
                      className={cn(
                        "inline-flex items-center rounded-full border px-2 py-0.5 text-xs font-medium",
                        classStyles[p.prediction_class]
                      )}
                    >
                      {p.prediction_class} · {classLabel(p.prediction_class)}
                    </span>
                    {p.trigger === "manual" && (
                      <span className="inline-flex items-center gap-1 rounded-full bg-primary/10 px-2 py-0.5 text-xs font-medium text-primary">
                        <Zap className="h-3 w-3" />
                        Manual
                      </span>
                    )}
                    <span className="ml-auto inline-flex items-center gap-1 text-xs text-muted-foreground">
                      <CalendarClock className="h-3 w-3" />
                      {formatTime(p.timestamp)}
                    </span>
                  </div>

                  <div className="mt-2 flex flex-wrap items-center gap-x-6 gap-y-2">
                    <div>
                      <p className="text-xs text-muted-foreground">Vital Score</p>
                      <p
                        className={cn(
                          "text-sm font-bold",
                          p.prediction_class === 0 && "text-emerald-500",
                          p.prediction_class === 1 && "text-amber-500",
                          p.prediction_class === 2 && "text-red-500"
                        )}
                      >
                        {p.crop_vital_score}/100
                      </p>
                    </div>
                    <div className="min-w-[140px]">
                      <p className="text-xs text-muted-foreground">
                        Confidence · {Math.round(p.confidence * 100)}%
                      </p>
                      <div className="mt-1 h-1.5 w-full rounded-full bg-muted overflow-hidden">
                        <div
                          className="h-full rounded-full bg-primary"
                          style={{ width: `${p.confidence * 100}%` }}
                        />
                      </div>
                    </div>
                    <div className="text-xs text-muted-foreground">
                      <span className="font-mono">{p.model_version}</span>
                    </div>
                    <div className="text-xs text-muted-foreground">
                      Inputs: {p.weather_inputs.temperature_c}°C ·{" "}
                      {p.weather_inputs.humidity_pct}% RH ·{" "}
                      {p.weather_inputs.precipitation_mm}mm
                    </div>
                  </div>
                </div>
              </li>
            ))}
          </ol>

          {filtered.length === 0 && (
            <p className="py-8 text-center text-muted-foreground text-sm">
              No predictions match the selected class filter.
            </p>
          )}
        </div>

        <div className="border-t border-border px-4 py-3">
          <p className="text-xs text-muted-foreground">
            {filtered.length} predictions · model{" "}
            <span className="font-mono">{history[0]?.model_version ?? "—"}</span>
          </p>
        </div>
      </div>
    </div>
  );
}
