import { RefreshCw, BrainCircuit } from "lucide-react";
import type { DashboardFarm, FarmRecord, RegionFilter } from "../types";
import { classLabel } from "../types";
import { cn, formatDate } from "../lib/utils";
import { DistrictMap } from "./DistrictMap";
import { DisclaimerBanner } from "./DisclaimerBanner";

interface PredictionDashboardProps {
  farms: DashboardFarm[];
  regionFilter: RegionFilter;
  onFarmSelect: (farm: FarmRecord) => void;
  onTrigger: (fieldId: string) => void;
  runningIds: Set<string>;
}

const classStyles = {
  0: "bg-emerald-500/10 text-emerald-500",
  1: "bg-amber-500/10 text-amber-500",
  2: "bg-red-500/10 text-red-500",
} as const;

export function PredictionDashboard({
  farms,
  regionFilter,
  onFarmSelect,
  onTrigger,
  runningIds,
}: PredictionDashboardProps) {
  return (
    <div className="space-y-6">
      <DisclaimerBanner />

      <DistrictMap
        farms={farms}
        regionFilter={regionFilter}
        onFarmSelect={onFarmSelect}
      />

      <div className="rounded-xl border border-border bg-card overflow-hidden">
        <div className="flex items-center gap-2 border-b border-border p-4">
          <BrainCircuit className="h-5 w-5 text-primary" />
          <h3 className="font-semibold text-foreground">Live Crop Vital Scores</h3>
          <span className="ml-auto text-xs text-muted-foreground">
            GET /api/admin/dashboard
          </span>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-border bg-muted/50">
                <th className="px-4 py-3 text-left font-semibold text-muted-foreground">Farm / Plot</th>
                <th className="px-4 py-3 text-left font-semibold text-muted-foreground">District</th>
                <th className="px-4 py-3 text-left font-semibold text-muted-foreground">Crop</th>
                <th className="px-4 py-3 text-left font-semibold text-muted-foreground">Vital Score (ML)</th>
                <th className="px-4 py-3 text-left font-semibold text-muted-foreground">Model Class</th>
                <th className="px-4 py-3 text-left font-semibold text-muted-foreground">Confidence</th>
                <th className="px-4 py-3 text-left font-semibold text-muted-foreground">Last Run</th>
                <th className="px-4 py-3 text-left font-semibold text-muted-foreground">Action</th>
              </tr>
            </thead>
            <tbody>
              {farms.map((farm) => {
                const running = runningIds.has(farm.field_id);
                return (
                  <tr
                    key={farm.field_id}
                    className="border-b border-border last:border-0 hover:bg-muted/30 transition-colors"
                  >
                    <td className="px-4 py-3">
                      <button
                        onClick={() => onFarmSelect(farm)}
                        className="text-left hover:underline"
                      >
                        <p className="font-medium text-foreground">{farm.farmer_name}</p>
                        <p className="text-xs text-muted-foreground font-mono">{farm.field_id}</p>
                      </button>
                    </td>
                    <td className="px-4 py-3 text-muted-foreground">{farm.district}</td>
                    <td className="px-4 py-3 text-muted-foreground">{farm.crop_type}</td>
                    <td className="px-4 py-3">
                      <span
                        className={cn(
                          "text-lg font-black",
                          farm.prediction_class === 0 && "text-emerald-500",
                          farm.prediction_class === 1 && "text-amber-500",
                          farm.prediction_class === 2 && "text-red-500"
                        )}
                      >
                        {farm.crop_vital_score}
                      </span>
                      <span className="text-xs text-muted-foreground">/100</span>
                    </td>
                    <td className="px-4 py-3">
                      <span
                        className={cn(
                          "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium",
                          classStyles[farm.prediction_class]
                        )}
                      >
                        {farm.prediction_class} · {classLabel(farm.prediction_class)}
                      </span>
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2">
                        <div className="h-1.5 w-14 rounded-full bg-muted overflow-hidden">
                          <div
                            className="h-full rounded-full bg-primary"
                            style={{ width: `${farm.confidence * 100}%` }}
                          />
                        </div>
                        <span className="text-xs font-medium text-foreground">
                          {Math.round(farm.confidence * 100)}%
                        </span>
                      </div>
                    </td>
                    <td className="px-4 py-3 text-xs text-muted-foreground">
                      {formatDate(farm.last_prediction_at.slice(0, 10))}
                    </td>
                    <td className="px-4 py-3">
                      <button
                        onClick={() => onTrigger(farm.field_id)}
                        disabled={running}
                        className="inline-flex items-center gap-1.5 rounded-lg bg-primary/10 px-2.5 py-1.5 text-xs font-medium text-primary hover:bg-primary/20 transition-colors disabled:opacity-50"
                        title="Re-run ML model with current weather"
                      >
                        <RefreshCw className={cn("h-3.5 w-3.5", running && "animate-spin")} />
                        {running ? "Running…" : "Re-run Model"}
                      </button>
                    </td>
                  </tr>
                );
              })}
              {farms.length === 0 && (
                <tr>
                  <td colSpan={8} className="px-4 py-8 text-center text-muted-foreground">
                    No farms match the current region/district filters.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
