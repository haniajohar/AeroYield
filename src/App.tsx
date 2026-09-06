import { useState, useEffect } from "react";
import {
  Satellite,
  Map,
  Table2,
  FileText,
  Megaphone,
  Moon,
  Sun,
  Menu,
  X,
  Wheat,
  BrainCircuit,
  History,
  CloudSun,
  Activity,
} from "lucide-react";
import { cn } from "./lib/utils";
import { useAdminData } from "./hooks/useAdminData";
import { usePredictions } from "./hooks/usePredictions";
import { KpiBar } from "./components/KpiBar";
import { DistrictMap } from "./components/DistrictMap";
import { FarmerTable } from "./components/FarmerTable";
import { TelemetrySidebar } from "./components/TelemetrySidebar";
import { AdvisoryAuditLog } from "./components/AdvisoryAuditLog";
import { EmergencyBroadcast } from "./components/EmergencyBroadcast";
import { PredictionDashboard } from "./components/PredictionDashboard";
import { PredictionHistory } from "./components/PredictionHistory";
import { ModelHealth } from "./components/ModelHealth";
import { WeatherFeed } from "./components/WeatherFeed";
import { DataSourceBadge } from "./components/DisclaimerBanner";
import { regions, districts } from "./data/mockAdminData";
import type { RegionFilter } from "./types";

type TabId =
  | "dashboard"
  | "farmers"
  | "predictions"
  | "history"
  | "model"
  | "weather"
  | "advisory"
  | "broadcast";

const navItems = [
  { id: "dashboard" as TabId, label: "GIS", icon: Map },
  { id: "farmers" as TabId, label: "Farmers", icon: Table2 },
  { id: "predictions" as TabId, label: "Predictions", icon: BrainCircuit },
  { id: "history" as TabId, label: "History", icon: History },
  { id: "model" as TabId, label: "Model", icon: Activity },
  { id: "weather" as TabId, label: "Weather", icon: CloudSun },
  { id: "advisory" as TabId, label: "Advisory", icon: FileText },
  { id: "broadcast" as TabId, label: "Alerts", icon: Megaphone },
];

export default function App() {
  const [activeTab, setActiveTab] = useState<TabId>("dashboard");
  const [darkMode, setDarkMode] = useState(true);
  const [mobileNav, setMobileNav] = useState(false);

  const {
    filteredFarms,
    farms,
    alerts,
    kpis,
    regionFilter,
    setRegionFilter,
    districtFilter,
    setDistrictFilter,
    selectedFarm,
    setSelectedFarm,
    updateAdvisoryStatus,
    sendEmergencyAlert,
  } = useAdminData();

  const {
    history: predictionHistoryList,
    metrics,
    live,
    runningIds,
    toast,
    triggerPrediction,
    filteredFarms: filteredPredictionFarms,
  } = usePredictions();

  useEffect(() => {
    document.documentElement.classList.toggle("dark", darkMode);
  }, [darkMode]);

  return (
    <div className="min-h-screen bg-background">
      {/* Top Navigation */}
      <header className="sticky top-0 z-40 border-b border-border bg-card/95 backdrop-blur-sm">
        <div className="mx-auto max-w-[1600px] px-4 lg:px-6">
          <div className="flex h-16 items-center justify-between">
            {/* Logo */}
            <div className="flex items-center gap-3">
              <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-primary/10">
                <Satellite className="h-5 w-5 text-primary" />
              </div>
              <div>
                <h1 className="text-lg font-bold text-foreground tracking-tight">AeroYield</h1>
                <p className="text-[10px] text-muted-foreground -mt-0.5 tracking-wide">
                  SATELLITE CROP INTELLIGENCE
                </p>
              </div>
            </div>

            {/* Desktop Nav */}
            <nav className="hidden md:flex items-center gap-1 overflow-x-auto no-scrollbar">
              {navItems.map((item) => (
                <button
                  key={item.id}
                  onClick={() => setActiveTab(item.id)}
                  className={cn(
                    "inline-flex items-center gap-2 rounded-lg px-3 py-2 text-sm font-medium transition-colors whitespace-nowrap",
                    activeTab === item.id
                      ? "bg-primary/10 text-primary"
                      : "text-muted-foreground hover:text-foreground hover:bg-accent"
                  )}
                >
                  <item.icon className="h-4 w-4" />
                  {item.label}
                </button>
              ))}
            </nav>

            {/* Right Controls */}
            <div className="flex items-center gap-2">
              <DataSourceBadge live={live} />
              <button
                onClick={() => setDarkMode(!darkMode)}
                className="rounded-lg p-2 text-muted-foreground hover:bg-accent hover:text-foreground transition-colors"
                title={darkMode ? "Switch to Light Mode" : "Switch to Dark Mode"}
              >
                {darkMode ? <Sun className="h-5 w-5" /> : <Moon className="h-5 w-5" />}
              </button>
              <button
                onClick={() => setMobileNav(!mobileNav)}
                className="md:hidden rounded-lg p-2 text-muted-foreground hover:bg-accent hover:text-foreground transition-colors"
              >
                {mobileNav ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
              </button>
            </div>
          </div>

          {/* Mobile Nav */}
          {mobileNav && (
            <div className="md:hidden border-t border-border pb-3 pt-2">
              {navItems.map((item) => (
                <button
                  key={item.id}
                  onClick={() => {
                    setActiveTab(item.id);
                    setMobileNav(false);
                  }}
                  className={cn(
                    "flex w-full items-center gap-2 rounded-lg px-3 py-2.5 text-sm font-medium transition-colors",
                    activeTab === item.id
                      ? "bg-primary/10 text-primary"
                      : "text-muted-foreground hover:text-foreground hover:bg-accent"
                  )}
                >
                  <item.icon className="h-4 w-4" />
                  {item.label}
                </button>
              ))}
            </div>
          )}
        </div>
      </header>

      {/* Main Content */}
      <main className="mx-auto max-w-[1600px] px-4 lg:px-6 py-6 space-y-6">
        {/* KPI Bar - always visible */}
        <KpiBar
          totalArea={kpis.totalArea}
          activeFarmers={kpis.activeFarmers}
          avgVitalScore={kpis.avgVitalScore}
          criticalPlots={kpis.criticalPlots}
        />

        {/* Region / District Filters */}
        {(activeTab === "dashboard" ||
          activeTab === "farmers" ||
          activeTab === "predictions" ||
          activeTab === "weather") && (
          <div className="flex flex-wrap items-center gap-3">
            <div className="flex items-center gap-2">
              <Wheat className="h-4 w-4 text-muted-foreground" />
              <span className="text-sm font-medium text-muted-foreground">Region:</span>
            </div>
            <div className="flex gap-1 rounded-lg bg-muted p-1">
              {regions.map((r) => (
                <button
                  key={r.value}
                  onClick={() => setRegionFilter(r.value as RegionFilter)}
                  className={cn(
                    "rounded-md px-3 py-1.5 text-xs font-medium transition-colors",
                    regionFilter === r.value
                      ? "bg-card text-foreground shadow-sm"
                      : "text-muted-foreground hover:text-foreground"
                  )}
                >
                  {r.label}
                </button>
              ))}
            </div>
            <div className="flex items-center gap-2 ml-auto">
              <span className="text-sm font-medium text-muted-foreground">District:</span>
              <select
                value={districtFilter}
                onChange={(e) => setDistrictFilter(e.target.value)}
                className="rounded-lg border border-input bg-background px-3 py-1.5 text-sm text-foreground focus:outline-none focus:ring-2 focus:ring-ring"
              >
                {districts.map((d) => (
                  <option key={d} value={d}>
                    {d}
                  </option>
                ))}
              </select>
            </div>
          </div>
        )}

        {/* Tab Content */}
        {activeTab === "dashboard" && (
          <div className="space-y-6">
            <DistrictMap
              farms={filteredFarms}
              regionFilter={regionFilter}
              onFarmSelect={setSelectedFarm}
            />
            <FarmerTable farms={filteredFarms} onSelectFarm={setSelectedFarm} />
          </div>
        )}

        {activeTab === "farmers" && (
          <FarmerTable farms={filteredFarms} onSelectFarm={setSelectedFarm} />
        )}

        {activeTab === "predictions" && (
          <PredictionDashboard
            farms={filteredPredictionFarms(regionFilter, districtFilter)}
            regionFilter={regionFilter}
            onFarmSelect={setSelectedFarm}
            onTrigger={triggerPrediction}
            runningIds={runningIds}
          />
        )}

        {activeTab === "history" && (
          <PredictionHistory history={predictionHistoryList} />
        )}

        {activeTab === "model" && <ModelHealth metrics={metrics} />}

        {activeTab === "weather" && (
          <WeatherFeed
            farms={filteredPredictionFarms(regionFilter, districtFilter)}
            regionFilter={regionFilter}
          />
        )}

        {activeTab === "advisory" && (
          <AdvisoryAuditLog farms={farms} onUpdateStatus={updateAdvisoryStatus} />
        )}

        {activeTab === "broadcast" && (
          <EmergencyBroadcast alerts={alerts} onSend={sendEmergencyAlert} />
        )}
      </main>

      {/* Footer */}
      <footer className="border-t border-border mt-8">
        <div className="mx-auto max-w-[1600px] px-4 lg:px-6 py-4 flex flex-col sm:flex-row items-center justify-between gap-2">
          <p className="text-xs text-muted-foreground">
            AeroYield &copy; 2026 &mdash; Satellite-Driven Crop Intelligence for Pakistan Agriculture
          </p>
          <p className="text-xs text-muted-foreground">
            Data refreshes every 6 hours via Sentinel-2 &amp; Landsat-9
          </p>
        </div>
      </footer>

      {/* Telemetry Sidebar Overlay */}
      {selectedFarm && (
        <>
          <div
            className="fixed inset-0 z-40 bg-black/50 backdrop-blur-sm"
            onClick={() => setSelectedFarm(null)}
          />
          <TelemetrySidebar
            farm={selectedFarm}
            onClose={() => setSelectedFarm(null)}
            onTriggerPrediction={triggerPrediction}
            predicting={runningIds.has(selectedFarm.field_id)}
          />
        </>
      )}

      {/* Prediction toast */}
      {toast && (
        <div className="fixed bottom-6 left-1/2 z-50 -translate-x-1/2 rounded-lg border border-border bg-card px-4 py-3 shadow-xl">
          <p className="text-sm text-foreground">{toast}</p>
        </div>
      )}
    </div>
  );
}
