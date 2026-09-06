import { Satellite, Users, Activity, AlertTriangle } from "lucide-react";
import { cn } from "../lib/utils";

interface KpiBarProps {
  totalArea: number;
  activeFarmers: number;
  avgVitalScore: number;
  criticalPlots: number;
}

const cards = [
  {
    key: "area",
    icon: Satellite,
    label: "Total Monitored Area",
    format: (v: number) => `${v.toLocaleString()} Hectares`,
    accent: "text-emerald-500",
    bg: "bg-emerald-500/10",
  },
  {
    key: "farmers",
    icon: Users,
    label: "Active Registered Farmers",
    format: (v: number) => `${v.toLocaleString()} Farmers`,
    accent: "text-blue-500",
    bg: "bg-blue-500/10",
  },
  {
    key: "vital",
    icon: Activity,
    label: "Regional Avg Vital Score",
    format: (v: number) => {
      const status = v >= 75 ? "Healthy" : v >= 45 ? "Moderate" : "Critical";
      return `${v}/100 — ${status}`;
    },
    accent: "text-amber-500",
    bg: "bg-amber-500/10",
  },
  {
    key: "critical",
    icon: AlertTriangle,
    label: "Active Critical Alerts",
    format: (v: number) => `${v} Plots at Risk`,
    accent: "text-red-500",
    bg: "bg-red-500/10",
  },
] as const;

export function KpiBar({ totalArea, activeFarmers, avgVitalScore, criticalPlots }: KpiBarProps) {
  const values = [totalArea, activeFarmers, avgVitalScore, criticalPlots];

  return (
    <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
      {cards.map((card, i) => (
        <div
          key={card.key}
          className="flex items-center gap-4 rounded-xl border border-border bg-card p-4 transition-all hover:shadow-md"
        >
          <div className={cn("flex h-12 w-12 items-center justify-center rounded-lg", card.bg)}>
            <card.icon className={cn("h-6 w-6", card.accent)} />
          </div>
          <div className="min-w-0">
            <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider">
              {card.label}
            </p>
            <p className="mt-0.5 text-lg font-bold text-foreground truncate">
              {card.format(values[i])}
            </p>
          </div>
        </div>
      ))}
    </div>
  );
}
