export interface FarmRecord {
  field_id: string;
  farmer_name: string;
  district: string;
  region: string;
  crop_type: string;
  crop_vital_score: number;
  soil_moisture_pct: number;
  ndvi_index: number;
  coordinates: [number, number];
  advisory_text_en: string;
  advisory_text_ur: string;
  last_updated: string;
  advisory_status: "Sent" | "Verified" | "Flagged";
  ndvi_history: { date: string; value: number }[];
}

export interface EmergencyAlert {
  id: string;
  district: string;
  message_en: string;
  message_ur: string;
  sent_at: string;
  recipient_count: number;
  severity: "high" | "medium" | "low";
}

export type RegionFilter =
  | "all"
  | "khyber_pakhtunkhwa"
  | "punjab";

export type DistrictFilter = string;

/** ML prediction class from the backend model: 0=Healthy, 1=Moderate, 2=Critical */
export type PredictionClass = 0 | 1 | 2;

/** Farm record enriched with live ML prediction output (GET /api/admin/dashboard) */
export interface DashboardFarm extends FarmRecord {
  prediction_class: PredictionClass;
  confidence: number;
  model_version: string;
  last_prediction_at: string;
  weather: WeatherData;
}

/** One ML prediction event (GET /api/admin/predictions) */
export interface PredictionRecord {
  prediction_id: string;
  field_id: string;
  farmer_name: string;
  district: string;
  crop_type: string;
  crop_vital_score: number;
  prediction_class: PredictionClass;
  confidence: number;
  model_version: string;
  timestamp: string;
  trigger: "scheduled" | "manual";
  weather_inputs: {
    temperature_c: number;
    humidity_pct: number;
    precipitation_mm: number;
  };
}

/** Model performance metrics (GET /api/admin/model-metrics) */
export interface ModelMetrics {
  model_version: string;
  model_type: string;
  accuracy: number;
  f1_score: number;
  precision: number;
  recall: number;
  confusion_matrix: number[][]; // [true][predicted], classes 0/1/2
  feature_importance: { feature: string; importance: number }[];
  trained_at: string;
  training_samples: number;
  known_limitations: string[];
}

/** NASA POWER weather snapshot for a farm (GET /api/farms/{id} → weather) */
export interface WeatherData {
  temperature_c: number;
  humidity_pct: number;
  precipitation_mm: number;
  wind_speed_kmh: number;
  solar_radiation: number;
  fetched_at: string;
  source: string;
}

export function classLabel(c: PredictionClass): string {
  if (c === 0) return "Healthy";
  if (c === 1) return "Moderate";
  return "Critical";
}
