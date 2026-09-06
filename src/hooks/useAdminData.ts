import { useState, useMemo, useCallback, useEffect } from "react";
import { farmRecords, emergencyAlerts } from "../data/mockAdminData";
import { api } from "../lib/api";
import type { FarmRecord, EmergencyAlert, RegionFilter } from "../types";

export function useAdminData() {
  const [farms, setFarms] = useState<FarmRecord[]>(farmRecords);
  const [alerts, setAlerts] = useState<EmergencyAlert[]>(emergencyAlerts);
  const [regionFilter, setRegionFilter] = useState<RegionFilter>("all");
  const [districtFilter, setDistrictFilter] = useState<string>("All Districts");
  const [selectedFarm, setSelectedFarm] = useState<FarmRecord | null>(null);
  const [farmsLive, setFarmsLive] = useState(false);

  // Fetch live farms from backend on mount (falls back to mock if unreachable)
  useEffect(() => {
    api.getFarms().then((liveFarms) => {
      if (liveFarms && liveFarms.length > 0) {
        setFarms(liveFarms);
        setFarmsLive(true);
      }
    });
  }, []);

  const filteredFarms = useMemo(() => {
    return farms.filter((f) => {
      const regionMatch = regionFilter === "all" || f.region === regionFilter;
      const districtMatch =
        districtFilter === "All Districts" || f.district === districtFilter;
      return regionMatch && districtMatch;
    });
  }, [farms, regionFilter, districtFilter]);

  const kpis = useMemo(() => {
    const totalArea = filteredFarms.length * 950;
    const avgVital =
      filteredFarms.length > 0
        ? Math.round(
            filteredFarms.reduce((s, f) => s + f.crop_vital_score, 0) /
              filteredFarms.length
          )
        : 0;
    const criticalCount = filteredFarms.filter(
      (f) => f.crop_vital_score < 45
    ).length;
    return {
      totalArea,
      activeFarmers: filteredFarms.length,
      avgVitalScore: avgVital,
      criticalPlots: criticalCount,
    };
  }, [filteredFarms]);

  const updateAdvisoryStatus = useCallback(
    (fieldId: string, status: FarmRecord["advisory_status"]) => {
      setFarms((prev) =>
        prev.map((f) =>
          f.field_id === fieldId ? { ...f, advisory_status: status } : f
        )
      );
    },
    []
  );

  const sendEmergencyAlert = useCallback(
    (district: string, messageEn: string, messageUr: string) => {
      const count = farms.filter((f) => f.district === district).length;
      const newAlert: EmergencyAlert = {
        id: `alert_${Date.now()}`,
        district,
        message_en: messageEn,
        message_ur: messageUr,
        sent_at: new Date().toISOString(),
        recipient_count: count * 20,
        severity: "high",
      };
      setAlerts((prev) => [newAlert, ...prev]);
    },
    [farms]
  );

  return {
    farms,
    filteredFarms,
    farmsLive,
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
  };
}
