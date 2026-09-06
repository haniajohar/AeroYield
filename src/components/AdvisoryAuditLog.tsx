import { useState } from "react";
import { CheckCircle, Flag, Bot, FileText, Languages } from "lucide-react";
import type { FarmRecord } from "../types";
import { cn, formatDate, getVitalStatus } from "../lib/utils";

interface AdvisoryAuditLogProps {
  farms: FarmRecord[];
  onUpdateStatus: (fieldId: string, status: FarmRecord["advisory_status"]) => void;
}

export function AdvisoryAuditLog({ farms, onUpdateStatus }: AdvisoryAuditLogProps) {
  const [expanded, setExpanded] = useState<string | null>(null);
  const [filter, setFilter] = useState<string>("all");

  const filtered = farms.filter(
    (f) => filter === "all" || f.advisory_status === filter
  );

  return (
    <div className="rounded-xl border border-border bg-card overflow-hidden">
      <div className="flex items-center justify-between border-b border-border p-4">
        <div className="flex items-center gap-2">
          <FileText className="h-5 w-5 text-primary" />
          <h3 className="font-semibold text-foreground">AI Advisory Audit Log</h3>
        </div>
        <select
          value={filter}
          onChange={(e) => setFilter(e.target.value)}
          className="rounded-lg border border-input bg-background px-3 py-1.5 text-sm text-foreground focus:outline-none focus:ring-2 focus:ring-ring"
        >
          <option value="all">All Advisories</option>
          <option value="Sent">Pending Review</option>
          <option value="Verified">Verified</option>
          <option value="Flagged">Flagged</option>
        </select>
      </div>

      <div className="divide-y divide-border">
        {filtered.map((farm) => (
          <div key={farm.field_id} className="transition-colors hover:bg-muted/20">
            {/* Row header */}
            <button
              onClick={() => setExpanded(expanded === farm.field_id ? null : farm.field_id)}
              className="w-full flex items-center justify-between px-4 py-3 text-left"
            >
              <div className="flex items-center gap-3 min-w-0">
                <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-primary/10 shrink-0">
                  <Bot className="h-4 w-4 text-primary" />
                </div>
                <div className="min-w-0">
                  <p className="text-sm font-medium text-foreground truncate">
                    {farm.farmer_name} &mdash; {farm.field_id}
                  </p>
                  <p className="text-xs text-muted-foreground">
                    {farm.district} &middot; {farm.crop_type} &middot; {formatDate(farm.last_updated)}
                  </p>
                </div>
              </div>
              <div className="flex items-center gap-2 shrink-0 ml-3">
                <span
                  className={cn(
                    "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium",
                    farm.advisory_status === "Verified" && "bg-emerald-500/10 text-emerald-500",
                    farm.advisory_status === "Sent" && "bg-blue-500/10 text-blue-500",
                    farm.advisory_status === "Flagged" && "bg-red-500/10 text-red-500"
                  )}
                >
                  {farm.advisory_status}
                </span>
                <svg
                  className={cn(
                    "h-4 w-4 text-muted-foreground transition-transform",
                    expanded === farm.field_id && "rotate-180"
                  )}
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                </svg>
              </div>
            </button>

            {/* Expanded detail */}
            {expanded === farm.field_id && (
              <div className="px-4 pb-4 space-y-4">
                {/* Telemetry inputs */}
                <div className="grid grid-cols-3 gap-2">
                  <div className="rounded-lg bg-background border border-border p-2 text-center">
                    <p className="text-xs text-muted-foreground">Vital Score</p>
                    <p className={cn("text-lg font-bold", (() => {
                      const s = getVitalStatus(farm.crop_vital_score);
                      return s.color === "green" ? "text-emerald-500" : s.color === "amber" ? "text-amber-500" : "text-red-500";
                    })())}>
                      {farm.crop_vital_score}
                    </p>
                  </div>
                  <div className="rounded-lg bg-background border border-border p-2 text-center">
                    <p className="text-xs text-muted-foreground">NDVI</p>
                    <p className="text-lg font-bold text-foreground">{farm.ndvi_index.toFixed(2)}</p>
                  </div>
                  <div className="rounded-lg bg-background border border-border p-2 text-center">
                    <p className="text-xs text-muted-foreground">Soil Moist.</p>
                    <p className="text-lg font-bold text-foreground">{farm.soil_moisture_pct}%</p>
                  </div>
                </div>

                {/* Advisory texts */}
                <div className="space-y-3">
                  <div className="rounded-lg bg-background border border-border p-3">
                    <div className="flex items-center gap-2 mb-1">
                      <Languages className="h-3.5 w-3.5 text-blue-500" />
                      <p className="text-xs font-semibold text-muted-foreground">English Advisory</p>
                    </div>
                    <p className="text-sm text-foreground leading-relaxed">{farm.advisory_text_en}</p>
                  </div>
                  <div className="rounded-lg bg-background border border-border p-3">
                    <div className="flex items-center gap-2 mb-1">
                      <Languages className="h-3.5 w-3.5 text-green-500" />
                      <p className="text-xs font-semibold text-muted-foreground">اردو ایڈوائسری</p>
                    </div>
                    <p className="text-sm text-foreground leading-relaxed text-right" dir="rtl">
                      {farm.advisory_text_ur}
                    </p>
                  </div>
                </div>

                {/* Action buttons */}
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => onUpdateStatus(farm.field_id, "Verified")}
                    className="inline-flex items-center gap-1.5 rounded-lg bg-emerald-500/10 px-3 py-2 text-xs font-medium text-emerald-500 hover:bg-emerald-500/20 transition-colors"
                  >
                    <CheckCircle className="h-3.5 w-3.5" />
                    Approve Advisory
                  </button>
                  <button
                    onClick={() => onUpdateStatus(farm.field_id, "Flagged")}
                    className="inline-flex items-center gap-1.5 rounded-lg bg-red-500/10 px-3 py-2 text-xs font-medium text-red-500 hover:bg-red-500/20 transition-colors"
                  >
                    <Flag className="h-3.5 w-3.5" />
                    Flag for Review
                  </button>
                </div>
              </div>
            )}
          </div>
        ))}
        {filtered.length === 0 && (
          <div className="px-4 py-8 text-center text-muted-foreground text-sm">
            No advisory records match the selected filter.
          </div>
        )}
      </div>
    </div>
  );
}
