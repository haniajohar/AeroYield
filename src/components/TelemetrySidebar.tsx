import { X, Droplets, Leaf, Thermometer, Calendar, RefreshCw, AlertTriangle } from "lucide-react";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Area,
  AreaChart,
} from "recharts";
import type { FarmRecord } from "../types";
import { cn, getVitalStatus, formatDate } from "../lib/utils";

interface TelemetrySidebarProps {
  farm: FarmRecord;
  onClose: () => void;
  onTriggerPrediction?: (fieldId: string) => void;
  predicting?: boolean;
}

/** Amber pill marking placeholder values pending satellite integration */
function EstimatedPill() {
  return (
    <span
      className="rounded-full bg-amber-500/10 px-1.5 py-0.5 text-[10px] font-semibold text-amber-500"
      title="Estimated placeholder until satellite data integration"
    >
      EST
    </span>
  );
}

export function TelemetrySidebar({ farm, onClose, onTriggerPrediction, predicting }: TelemetrySidebarProps) {
  const status = getVitalStatus(farm.crop_vital_score);

  const ndviData = farm.ndvi_history.map((h) => ({
    date: new Date(h.date).toLocaleDateString("en-PK", { month: "short", day: "numeric" }),
    ndvi: parseFloat(h.value.toFixed(3)),
  }));

  return (
    <div className="fixed inset-y-0 right-0 z-50 w-full max-w-md border-l border-border bg-card shadow-2xl overflow-y-auto">
      {/* Header */}
      <div className="sticky top-0 z-10 flex items-center justify-between border-b border-border bg-card/95 backdrop-blur-sm p-4">
        <div>
          <h3 className="font-bold text-foreground text-lg">{farm.farmer_name}</h3>
          <p className="text-xs text-muted-foreground">{farm.field_id} &middot; {farm.district}</p>
        </div>
        <button
          onClick={onClose}
          className="rounded-lg p-2 text-muted-foreground hover:bg-accent hover:text-foreground transition-colors"
        >
          <X className="h-5 w-5" />
        </button>
      </div>

      <div className="p-4 space-y-6">
        {/* Vital Score Badge */}
        <div className="flex items-center justify-between rounded-xl border border-border bg-background p-4">
          <div>
            <p className="text-xs text-muted-foreground uppercase tracking-wider">Crop Vital Score</p>
            <p
              className={cn(
                "mt-1 text-3xl font-black",
                status.color === "green" && "text-emerald-500",
                status.color === "amber" && "text-amber-500",
                status.color === "red" && "text-red-500"
              )}
            >
              {farm.crop_vital_score}
              <span className="text-lg font-normal text-muted-foreground">/100</span>
            </p>
            <p
              className={cn(
                "text-sm font-semibold mt-0.5",
                status.color === "green" && "text-emerald-500",
                status.color === "amber" && "text-amber-500",
                status.color === "red" && "text-red-500"
              )}
            >
              {status.label}
            </p>
          </div>
          <div
            className={cn(
              "flex h-16 w-16 items-center justify-center rounded-full",
              status.color === "green" && "bg-emerald-500/10",
              status.color === "amber" && "bg-amber-500/10",
              status.color === "red" && "bg-red-500/10"
            )}
          >
            <Leaf
              className={cn(
                "h-8 w-8",
                status.color === "green" && "text-emerald-500",
                status.color === "amber" && "text-amber-500",
                status.color === "red" && "text-red-500"
              )}
            />
          </div>
        </div>

        {/* Telemetry Cards */}
        <div className="grid grid-cols-2 gap-3">
          <div className="rounded-lg border border-border bg-background p-3">
            <div className="flex items-center gap-2 mb-1">
              <Leaf className="h-4 w-4 text-emerald-500" />
              <span className="text-xs text-muted-foreground">NDVI Index</span>
              <EstimatedPill />
            </div>
            <p className="text-xl font-bold text-foreground">{farm.ndvi_index.toFixed(2)}</p>
          </div>
          <div className="rounded-lg border border-border bg-background p-3">
            <div className="flex items-center gap-2 mb-1">
              <Droplets className="h-4 w-4 text-blue-500" />
              <span className="text-xs text-muted-foreground">Soil Moisture</span>
              <EstimatedPill />
            </div>
            <p className="text-xl font-bold text-foreground">{farm.soil_moisture_pct}%</p>
          </div>
          <div className="rounded-lg border border-border bg-background p-3">
            <div className="flex items-center gap-2 mb-1">
              <Thermometer className="h-4 w-4 text-orange-500" />
              <span className="text-xs text-muted-foreground">Crop Type</span>
            </div>
            <p className="text-xl font-bold text-foreground">{farm.crop_type}</p>
          </div>
          <div className="rounded-lg border border-border bg-background p-3">
            <div className="flex items-center gap-2 mb-1">
              <Calendar className="h-4 w-4 text-purple-500" />
              <span className="text-xs text-muted-foreground">Last Updated</span>
            </div>
            <p className="text-sm font-bold text-foreground">{formatDate(farm.last_updated)}</p>
          </div>
        </div>

        {/* NDVI Trend Chart */}
        <div className="rounded-xl border border-border bg-background p-4">
          <h4 className="text-sm font-semibold text-foreground mb-3">NDVI Trend (6 Months)</h4>
          <div className="h-48">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={ndviData}>
                <defs>
                  <linearGradient id="ndviGrad" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#22c55e" stopOpacity={0.3} />
                    <stop offset="95%" stopColor="#22c55e" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                <XAxis dataKey="date" tick={{ fontSize: 10, fill: "hsl(var(--muted-foreground))" }} />
                <YAxis domain={[0, 1]} tick={{ fontSize: 10, fill: "hsl(var(--muted-foreground))" }} />
                <Tooltip
                  contentStyle={{
                    backgroundColor: "hsl(var(--card))",
                    border: "1px solid hsl(var(--border))",
                    borderRadius: "8px",
                    fontSize: "12px",
                  }}
                />
                <Area
                  type="monotone"
                  dataKey="ndvi"
                  stroke="#22c55e"
                  strokeWidth={2}
                  fill="url(#ndviGrad)"
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* AI Advisory */}
        <div className="rounded-xl border border-border bg-background p-4">
          <h4 className="text-sm font-semibold text-foreground mb-3">AI-Generated Advisory</h4>
          <div className="space-y-3">
            <div>
              <p className="text-xs text-muted-foreground mb-1">English</p>
              <p className="text-sm text-foreground leading-relaxed">{farm.advisory_text_en}</p>
            </div>
            <div className="border-t border-border pt-3">
              <p className="text-xs text-muted-foreground mb-1">اردو (Urdu)</p>
              <p className="text-sm text-foreground leading-relaxed text-right" dir="rtl">
                {farm.advisory_text_ur}
              </p>
            </div>
          </div>
        </div>

        {/* Coordinates */}
        <div className="rounded-lg border border-border bg-background p-3">
          <p className="text-xs text-muted-foreground">
            GPS: {farm.coordinates[0].toFixed(4)}°N, {farm.coordinates[1].toFixed(4)}°E
          </p>
        </div>

        {/* Model disclaimer */}
        <div className="flex items-start gap-2 rounded-lg border border-amber-500/40 bg-amber-500/10 p-3">
          <AlertTriangle className="mt-0.5 h-4 w-4 shrink-0 text-amber-500" />
          <p className="text-xs text-foreground">
            Predictions are weather-based proxy estimates, not field-validated
            observations. NDVI and soil moisture are placeholders until satellite
            data integration.
          </p>
        </div>

        {/* Re-run ML prediction */}
        {onTriggerPrediction && (
          <button
            onClick={() => onTriggerPrediction(farm.field_id)}
            disabled={predicting}
            className="inline-flex w-full items-center justify-center gap-2 rounded-lg bg-primary px-4 py-2.5 text-sm font-semibold text-primary-foreground hover:bg-primary/90 transition-colors disabled:opacity-50"
          >
            <RefreshCw className={cn("h-4 w-4", predicting && "animate-spin")} />
            {predicting ? "Running Model…" : "Re-run ML Prediction"}
          </button>
        )}
      </div>
    </div>
  );
}
