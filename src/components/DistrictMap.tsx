import { Component, useEffect, useMemo } from "react";
import { MapContainer, TileLayer, Marker, Popup, useMap } from "react-leaflet";
import L from "leaflet";
import type { FarmRecord, RegionFilter } from "../types";

// Fix default marker icon issue with webpack/vite
delete (L.Icon.Default.prototype as any)._getIconUrl;

// ---------------------------------------------------------------------------
// ErrorBoundary — catches any marker/tile crash so the dashboard stays alive
// ---------------------------------------------------------------------------
interface EBProps { children: React.ReactNode; fallback: React.ReactNode }
interface EBState { hasError: boolean }

class MapErrorBoundary extends Component<EBProps, EBState> {
  constructor(props: EBProps) {
    super(props);
    this.state = { hasError: false };
  }
  static getDerivedStateFromError(): EBState {
    return { hasError: true };
  }
  render() {
    if (this.state.hasError) return this.props.fallback;
    return this.props.children;
  }
}

// ---------------------------------------------------------------------------
// Coordinate guard — returns true only for valid [lat, lng] tuples
// ---------------------------------------------------------------------------
function hasValidCoords(
  c: unknown
): c is [number, number] | (number)[] {
  if (!Array.isArray(c) || c.length < 2) return false;
  const [lat, lng] = c as number[];
  return (
    typeof lat === "number" &&
    typeof lng === "number" &&
    Number.isFinite(lat) &&
    Number.isFinite(lng) &&
    lat >= -90 && lat <= 90 &&
    lng >= -180 && lng <= 180
  );
}

// ---------------------------------------------------------------------------
// Icons
// ---------------------------------------------------------------------------
function createColoredIcon(color: "green" | "amber" | "red") {
  const colors = {
    green: "#22c55e",
    amber: "#f59e0b",
    red: "#ef4444",
  };
  return L.divIcon({
    className: "custom-pin",
    html: `<svg width="28" height="40" viewBox="0 0 28 40" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M14 0C6.268 0 0 6.268 0 14c0 10.5 14 26 14 26s14-15.5 14-26C28 6.268 21.732 0 14 0z" fill="${colors[color]}"/>
      <circle cx="14" cy="14" r="6" fill="white" fill-opacity="0.9"/>
    </svg>`,
    iconSize: [28, 40],
    iconAnchor: [14, 40],
    popupAnchor: [0, -40],
  });
}

const regionCenters: Record<string, [number, number]> = {
  all: [32.5, 71.5],
  khyber_pakhtunkhwa: [34.3, 71.8],
  punjab: [30.5, 71.5],
};

const regionZoom: Record<string, number> = {
  all: 6,
  khyber_pakhtunkhwa: 9,
  punjab: 9,
};

function MapUpdater({ center, zoom }: { center: [number, number]; zoom: number }) {
  const map = useMap();
  useEffect(() => {
    map.flyTo(center, zoom, { duration: 1.2 });
  }, [center, zoom, map]);
  return null;
}

// ---------------------------------------------------------------------------
// Safe marker — skips farms with missing / invalid coordinates
// ---------------------------------------------------------------------------
function SafeMarker({
  farm,
  onFarmSelect,
  getIcon,
}: {
  farm: FarmRecord;
  onFarmSelect: (f: FarmRecord) => void;
  getIcon: (score: number) => L.DivIcon;
}) {
  if (!hasValidCoords(farm.coordinates)) return null;

  return (
    <Marker
      position={[farm.coordinates[0], farm.coordinates[1]]}
      icon={getIcon(farm.crop_vital_score)}
      eventHandlers={{ click: () => onFarmSelect(farm) }}
    >
      <Popup>
        <div className="text-sm">
          <p className="font-bold text-gray-900">{farm.farmer_name}</p>
          <p className="text-gray-600">{farm.field_id}</p>
          <p className="mt-1">
            <span className="font-semibold">Vital:</span>{" "}
            <span
              className={
                farm.crop_vital_score >= 75
                  ? "text-green-600"
                  : farm.crop_vital_score >= 45
                  ? "text-amber-600"
                  : "text-red-600"
              }
            >
              {farm.crop_vital_score}/100
            </span>
          </p>
        </div>
      </Popup>
    </Marker>
  );
}

// ---------------------------------------------------------------------------
// Main DistrictMap
// ---------------------------------------------------------------------------
interface DistrictMapProps {
  farms: FarmRecord[];
  regionFilter: RegionFilter;
  onFarmSelect: (farm: FarmRecord) => void;
}

export function DistrictMap({ farms, regionFilter, onFarmSelect }: DistrictMapProps) {
  const center = useMemo(() => regionCenters[regionFilter] || regionCenters.all, [regionFilter]);
  const zoom = useMemo(() => regionZoom[regionFilter] || 6, [regionFilter]);

  const getIcon = (score: number) => {
    if (score >= 75) return createColoredIcon("green");
    if (score >= 45) return createColoredIcon("amber");
    return createColoredIcon("red");
  };

  const plottedCount = farms.filter((f) => hasValidCoords(f.coordinates)).length;

  return (
    <div className="relative h-[500px] w-full overflow-hidden rounded-xl border border-border">
      <MapErrorBoundary
        fallback={
          <div className="flex h-full w-full items-center justify-center bg-card">
            <div className="text-center">
              <p className="text-sm font-semibold text-foreground">Map unavailable</p>
              <p className="text-xs text-muted-foreground mt-1">
                A rendering error occurred. The rest of the dashboard is still functional.
              </p>
            </div>
          </div>
        }
      >
        <MapContainer
          center={center}
          zoom={zoom}
          scrollWheelZoom={true}
          className="h-full w-full"
        >
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />
          <MapUpdater center={center} zoom={zoom} />
          {farms.map((farm) => (
            <SafeMarker
              key={farm.field_id}
              farm={farm}
              onFarmSelect={onFarmSelect}
              getIcon={getIcon}
            />
          ))}
        </MapContainer>

        {/* Map Legend */}
        <div className="absolute bottom-4 left-4 z-[1000] rounded-lg border border-border bg-card/95 backdrop-blur-sm p-3 shadow-lg">
          <p className="text-xs font-semibold text-foreground mb-2">Vital Score Legend</p>
          <div className="space-y-1.5">
            <div className="flex items-center gap-2">
              <span className="h-3 w-3 rounded-full bg-emerald-500" />
              <span className="text-xs text-muted-foreground">75–100 Healthy</span>
            </div>
            <div className="flex items-center gap-2">
              <span className="h-3 w-3 rounded-full bg-amber-500" />
              <span className="text-xs text-muted-foreground">45–74 Moderate</span>
            </div>
            <div className="flex items-center gap-2">
              <span className="h-3 w-3 rounded-full bg-red-500" />
              <span className="text-xs text-muted-foreground">0–44 Critical</span>
            </div>
          </div>
          {plottedCount < farms.length && (
            <p className="text-[10px] text-muted-foreground mt-2">
              {farms.length - plottedCount} farm(s) without coordinates skipped
            </p>
          )}
        </div>
      </MapErrorBoundary>
    </div>
  );
}
