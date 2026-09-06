import { useMemo, useState } from "react";
import { Search, CloudSun, Thermometer, Droplets, CloudRain, Wind, Sun } from "lucide-react";
import type { DashboardFarm, RegionFilter } from "../types";
import { classLabel } from "../types";
import { cn } from "../lib/utils";

interface WeatherFeedProps {
  farms: DashboardFarm[];
  regionFilter: RegionFilter;
}

function timeAgo(iso: string) {
  const diff = Date.now() - Date.parse(iso);
  const h = Math.floor(diff / 3600000);
  if (h < 1) return "just now";
  if (h < 24) return `${h}h ago`;
  return `${Math.floor(h / 24)}d ago`;
}

export function WeatherFeed({ farms, regionFilter }: WeatherFeedProps) {
  const [search, setSearch] = useState("");

  const filtered = useMemo(() => {
    const q = search.toLowerCase();
    return farms.filter((f) => {
      const regionMatch = regionFilter === "all" || f.region === regionFilter;
      const searchMatch =
        !q ||
        f.farmer_name.toLowerCase().includes(q) ||
        f.field_id.toLowerCase().includes(q) ||
        f.district.toLowerCase().includes(q);
      return regionMatch && searchMatch;
    });
  }, [farms, search, regionFilter]);

  return (
    <div className="rounded-xl border border-border bg-card overflow-hidden">
      <div className="flex flex-wrap items-center gap-3 border-b border-border p-4">
        <CloudSun className="h-5 w-5 text-primary" />
        <h3 className="font-semibold text-foreground">Weather Feed</h3>
        <span className="text-xs text-muted-foreground">
          NASA POWER · GET /api/farms/{"{id}"}
        </span>
        <div className="relative ml-auto">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input
            type="text"
            placeholder="Search farm or district..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-56 rounded-lg border border-input bg-background pl-9 pr-3 py-2 text-sm text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring"
          />
        </div>
      </div>

      <div className="grid gap-4 p-4 sm:grid-cols-2 xl:grid-cols-3">
        {filtered.map((farm) => {
          const w = farm.weather;
          return (
            <div
              key={farm.field_id}
              className="rounded-xl border border-border bg-background p-4"
            >
              <div className="flex items-start justify-between">
                <div>
                  <p className="font-medium text-foreground">{farm.farmer_name}</p>
                  <p className="text-xs text-muted-foreground font-mono">
                    {farm.field_id} · {farm.district}
                  </p>
                </div>
                <span
                  className={cn(
                    "inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium",
                    farm.prediction_class === 0 && "bg-emerald-500/10 text-emerald-500",
                    farm.prediction_class === 1 && "bg-amber-500/10 text-amber-500",
                    farm.prediction_class === 2 && "bg-red-500/10 text-red-500"
                  )}
                >
                  {classLabel(farm.prediction_class)}
                </span>
              </div>

              {/* Temperature hero */}
              <div className="mt-3 flex items-end gap-3">
                <div className="flex h-14 w-14 items-center justify-center rounded-xl bg-orange-500/10">
                  <Thermometer className="h-7 w-7 text-orange-500" />
                </div>
                <div>
                  <p className="text-3xl font-black text-foreground">
                    {w.temperature_c}°C
                  </p>
                  <p className="text-xs text-muted-foreground">
                    {w.source} · {timeAgo(w.fetched_at)}
                  </p>
                </div>
              </div>

              {/* Other metrics */}
              <div className="mt-4 grid grid-cols-2 gap-2">
                <div className="flex items-center gap-2 rounded-lg bg-muted/50 px-2.5 py-2">
                  <Droplets className="h-4 w-4 text-blue-500 shrink-0" />
                  <div>
                    <p className="text-[10px] text-muted-foreground leading-none">Humidity</p>
                    <p className="text-sm font-bold text-foreground">{w.humidity_pct}%</p>
                  </div>
                </div>
                <div className="flex items-center gap-2 rounded-lg bg-muted/50 px-2.5 py-2">
                  <CloudRain className="h-4 w-4 text-sky-500 shrink-0" />
                  <div>
                    <p className="text-[10px] text-muted-foreground leading-none">Precip.</p>
                    <p className="text-sm font-bold text-foreground">{w.precipitation_mm} mm</p>
                  </div>
                </div>
                <div className="flex items-center gap-2 rounded-lg bg-muted/50 px-2.5 py-2">
                  <Wind className="h-4 w-4 text-teal-500 shrink-0" />
                  <div>
                    <p className="text-[10px] text-muted-foreground leading-none">Wind</p>
                    <p className="text-sm font-bold text-foreground">{w.wind_speed_kmh} km/h</p>
                  </div>
                </div>
                <div className="flex items-center gap-2 rounded-lg bg-muted/50 px-2.5 py-2">
                  <Sun className="h-4 w-4 text-yellow-500 shrink-0" />
                  <div>
                    <p className="text-[10px] text-muted-foreground leading-none">Solar Rad.</p>
                    <p className="text-sm font-bold text-foreground">
                      {w.solar_radiation} MJ/m²
                    </p>
                  </div>
                </div>
              </div>

              <p className="mt-3 text-[10px] text-muted-foreground">
                GPS {farm.coordinates[0].toFixed(4)}°N, {farm.coordinates[1].toFixed(4)}°E ·
                these inputs feed the ML model
              </p>
            </div>
          );
        })}
      </div>

      {filtered.length === 0 && (
        <p className="py-8 text-center text-muted-foreground text-sm">
          No farms match your search.
        </p>
      )}
    </div>
  );
}
