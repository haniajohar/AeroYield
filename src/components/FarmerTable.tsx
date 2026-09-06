import { useState, useMemo } from "react";
import { Search, Eye, MessageSquare } from "lucide-react";
import type { FarmRecord } from "../types";
import { cn, getVitalStatus, formatDate } from "../lib/utils";

interface FarmerTableProps {
  farms: FarmRecord[];
  onSelectFarm: (farm: FarmRecord) => void;
}

export function FarmerTable({ farms, onSelectFarm }: FarmerTableProps) {
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("all");

  const filtered = useMemo(() => {
    return farms.filter((f) => {
      const q = search.toLowerCase();
      const searchMatch =
        !q ||
        f.farmer_name.toLowerCase().includes(q) ||
        f.field_id.toLowerCase().includes(q) ||
        f.district.toLowerCase().includes(q) ||
        f.crop_type.toLowerCase().includes(q);
      const statusMatch = statusFilter === "all" || f.advisory_status === statusFilter;
      return searchMatch && statusMatch;
    });
  }, [farms, search, statusFilter]);

  return (
    <div className="rounded-xl border border-border bg-card overflow-hidden">
      {/* Toolbar */}
      <div className="flex flex-col sm:flex-row gap-3 border-b border-border p-4">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input
            type="text"
            placeholder="Search by farmer, plot ID, district, crop..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full rounded-lg border border-input bg-background pl-9 pr-3 py-2 text-sm text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring"
          />
        </div>
        <select
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
          className="rounded-lg border border-input bg-background px-3 py-2 text-sm text-foreground focus:outline-none focus:ring-2 focus:ring-ring"
        >
          <option value="all">All Status</option>
          <option value="Sent">Sent</option>
          <option value="Verified">Verified</option>
          <option value="Flagged">Flagged</option>
        </select>
      </div>

      {/* Table */}
      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-border bg-muted/50">
              <th className="px-4 py-3 text-left font-semibold text-muted-foreground">Plot ID & Farmer</th>
              <th className="px-4 py-3 text-left font-semibold text-muted-foreground">District</th>
              <th className="px-4 py-3 text-left font-semibold text-muted-foreground">Crop</th>
              <th className="px-4 py-3 text-left font-semibold text-muted-foreground">Vital Score</th>
              <th className="px-4 py-3 text-left font-semibold text-muted-foreground">Last Satellite</th>
              <th className="px-4 py-3 text-left font-semibold text-muted-foreground">Advisory</th>
              <th className="px-4 py-3 text-left font-semibold text-muted-foreground">Actions</th>
            </tr>
          </thead>
          <tbody>
            {filtered.map((farm) => {
              const status = getVitalStatus(farm.crop_vital_score);
              return (
                <tr
                  key={farm.field_id}
                  className="border-b border-border last:border-0 hover:bg-muted/30 transition-colors"
                >
                  <td className="px-4 py-3">
                    <div>
                      <p className="font-medium text-foreground">{farm.farmer_name}</p>
                      <p className="text-xs text-muted-foreground">{farm.field_id}</p>
                    </div>
                  </td>
                  <td className="px-4 py-3 text-muted-foreground">{farm.district}</td>
                  <td className="px-4 py-3">
                    <span className="inline-flex items-center rounded-full bg-muted px-2.5 py-0.5 text-xs font-medium text-foreground">
                      {farm.crop_type}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-2">
                      <div className="h-2 w-16 rounded-full bg-muted overflow-hidden">
                        <div
                          className={cn(
                            "h-full rounded-full transition-all",
                            status.color === "green" && "bg-emerald-500",
                            status.color === "amber" && "bg-amber-500",
                            status.color === "red" && "bg-red-500"
                          )}
                          style={{ width: `${farm.crop_vital_score}%` }}
                        />
                      </div>
                      <span
                        className={cn(
                          "text-xs font-bold",
                          status.color === "green" && "text-emerald-500",
                          status.color === "amber" && "text-amber-500",
                          status.color === "red" && "text-red-500"
                        )}
                      >
                        {farm.crop_vital_score}
                      </span>
                    </div>
                  </td>
                  <td className="px-4 py-3 text-muted-foreground text-xs">
                    {formatDate(farm.last_updated)}
                  </td>
                  <td className="px-4 py-3">
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
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-1">
                      <button
                        onClick={() => onSelectFarm(farm)}
                        className="inline-flex items-center gap-1 rounded-lg px-2.5 py-1.5 text-xs font-medium text-foreground hover:bg-accent transition-colors"
                        title="View Telemetry"
                      >
                        <Eye className="h-3.5 w-3.5" />
                        <span className="hidden xl:inline">Telemetry</span>
                      </button>
                      <button
                        className="inline-flex items-center gap-1 rounded-lg px-2.5 py-1.5 text-xs font-medium text-foreground hover:bg-accent transition-colors"
                        title="Send SMS/WhatsApp"
                      >
                        <MessageSquare className="h-3.5 w-3.5" />
                        <span className="hidden xl:inline">SMS</span>
                      </button>
                    </div>
                  </td>
                </tr>
              );
            })}
            {filtered.length === 0 && (
              <tr>
                <td colSpan={7} className="px-4 py-8 text-center text-muted-foreground">
                  No farm records found matching your criteria.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
      <div className="border-t border-border px-4 py-3">
        <p className="text-xs text-muted-foreground">
          Showing {filtered.length} of {farms.length} monitored plots
        </p>
      </div>
    </div>
  );
}
