import type {
  FarmRecord,
  EmergencyAlert,
  DashboardFarm,
  PredictionRecord,
  ModelMetrics,
  WeatherData,
  PredictionClass,
} from "../types";

function generateNdviHistory(base: number, months: number = 6): { date: string; value: number }[] {
  const history: { date: string; value: number }[] = [];
  const now = new Date("2026-05-18");
  for (let i = months; i >= 0; i--) {
    const d = new Date(now);
    d.setMonth(d.getMonth() - i);
    const variation = (Math.random() - 0.5) * 0.15;
    history.push({
      date: d.toISOString().slice(0, 10),
      value: Math.max(0.1, Math.min(0.95, base + variation)),
    });
  }
  return history;
}

export const farmRecords: FarmRecord[] = [
  {
    field_id: "mardan_plot_01",
    farmer_name: "Khan Muhammad",
    district: "Mardan",
    region: "khyber_pakhtunkhwa",
    crop_type: "Maize",
    crop_vital_score: 78,
    soil_moisture_pct: 68.5,
    ndvi_index: 0.72,
    coordinates: [34.1989, 72.0404],
    advisory_text_en: "Soil moisture is optimal. No irrigation required today.",
    advisory_text_ur: "زمین میں نمی مناسب ہے۔ آج آبپاشی کی ضرورت نہیں ہے۔",
    last_updated: "2026-05-18",
    advisory_status: "Verified",
    ndvi_history: generateNdviHistory(0.72),
  },
  {
    field_id: "mardan_plot_02",
    farmer_name: "Sher Ali Khan",
    district: "Mardan",
    region: "khyber_pakhtunkhwa",
    crop_type: "Wheat",
    crop_vital_score: 85,
    soil_moisture_pct: 72.0,
    ndvi_index: 0.81,
    coordinates: [34.2105, 72.0580],
    advisory_text_en: "Crop health excellent. Continue current management practices.",
    advisory_text_ur: "فصل کی صحت بہترین ہے۔ موجودہ طریقہ کار جاری رکھیں۔",
    last_updated: "2026-05-17",
    advisory_status: "Verified",
    ndvi_history: generateNdviHistory(0.81),
  },
  {
    field_id: "mardan_plot_03",
    farmer_name: "Fazal Rahman",
    district: "Mardan",
    region: "khyber_pakhtunkhwa",
    crop_type: "Maize",
    crop_vital_score: 38,
    soil_moisture_pct: 31.2,
    ndvi_index: 0.35,
    coordinates: [34.1850, 72.0250],
    advisory_text_en: "CRITICAL: Severe water stress detected. Immediate irrigation required.",
    advisory_text_ur: "انتباہ: شدید پانی کی کمی۔ فوری آبپاشی ضروری ہے۔",
    last_updated: "2026-05-18",
    advisory_status: "Sent",
    ndvi_history: generateNdviHistory(0.35),
  },
  {
    field_id: "mardan_plot_04",
    farmer_name: "Gulzar Ahmad",
    district: "Mardan",
    region: "khyber_pakhtunkhwa",
    crop_type: "Wheat",
    crop_vital_score: 52,
    soil_moisture_pct: 44.8,
    ndvi_index: 0.51,
    coordinates: [34.2200, 72.0700],
    advisory_text_en: "Moderate stress detected. Schedule irrigation within 24 hours.",
    advisory_text_ur: "درمیانہ دباؤ محسوس ہوا۔ 24 گھنٹے میں آبپاشی کا شیڈول بنائیں۔",
    last_updated: "2026-05-16",
    advisory_status: "Sent",
    ndvi_history: generateNdviHistory(0.51),
  },
  {
    field_id: "swat_plot_01",
    farmer_name: "Muhammad Yousaf",
    district: "Swat",
    region: "khyber_pakhtunkhwa",
    crop_type: "Maize",
    crop_vital_score: 91,
    soil_moisture_pct: 78.3,
    ndvi_index: 0.88,
    coordinates: [34.7465, 72.3557],
    advisory_text_en: "Excellent crop health. Maintain current irrigation schedule.",
    advisory_text_ur: "بہترین فصل کی صحت۔ موجودہ آبپاشی کا شیڈول برقرار رکھیں۔",
    last_updated: "2026-05-18",
    advisory_status: "Verified",
    ndvi_history: generateNdviHistory(0.88),
  },
  {
    field_id: "swat_plot_02",
    farmer_name: "Said Badshah",
    district: "Swat",
    region: "khyber_pakhtunkhwa",
    crop_type: "Peach",
    crop_vital_score: 67,
    soil_moisture_pct: 55.1,
    ndvi_index: 0.62,
    coordinates: [34.7800, 72.3900],
    advisory_text_en: "Orchard health moderate. Consider foliar spray for nutrient boost.",
    advisory_text_ur: "باغ کی صعت درمیانی ہے۔ غذائیت کے لیے پتوں پر سپرے کریں۔",
    last_updated: "2026-05-17",
    advisory_status: "Sent",
    ndvi_history: generateNdviHistory(0.62),
  },
  {
    field_id: "swat_plot_03",
    farmer_name: "Amir Nawaz",
    district: "Swat",
    region: "khyber_pakhtunkhwa",
    crop_type: "Maize",
    crop_vital_score: 28,
    soil_moisture_pct: 22.5,
    ndvi_index: 0.28,
    coordinates: [34.7200, 72.3200],
    advisory_text_en: "CRITICAL: Pest infestation suspected. Dispatch field officer for inspection.",
    advisory_text_ur: "انتباہ: کیڑوں کے حملے کا شبہ۔ فیلڈ افسر کو معائنے کے لیے بھیجیں۔",
    last_updated: "2026-05-18",
    advisory_status: "Flagged",
    ndvi_history: generateNdviHistory(0.28),
  },
  {
    field_id: "peshawar_plot_01",
    farmer_name: "Arshad Mahmood",
    district: "Peshawar",
    region: "khyber_pakhtunkhwa",
    crop_type: "Wheat",
    crop_vital_score: 74,
    soil_moisture_pct: 61.0,
    ndvi_index: 0.69,
    coordinates: [33.9984, 71.5469],
    advisory_text_en: "Crop approaching maturity. Reduce irrigation frequency.",
    advisory_text_ur: "فصل پختگی کے قریب ہے۔ آبپاشی کی تعدد کم کریں۔",
    last_updated: "2026-05-15",
    advisory_status: "Verified",
    ndvi_history: generateNdviHistory(0.69),
  },
  {
    field_id: "peshawar_plot_02",
    farmer_name: "Hidayat Ullah",
    district: "Peshawar",
    region: "khyber_pakhtunkhwa",
    crop_type: "Maize",
    crop_vital_score: 43,
    soil_moisture_pct: 35.7,
    ndvi_index: 0.42,
    coordinates: [34.0200, 71.5800],
    advisory_text_en: "Water stress detected. Recommend drip irrigation immediately.",
    advisory_text_ur: "پانی کا دباؤ محسوس ہوا۔ فوری ڈرپ آبپاشی کی سفارش۔",
    last_updated: "2026-05-18",
    advisory_status: "Sent",
    ndvi_history: generateNdviHistory(0.42),
  },
  {
    field_id: "charsadda_plot_01",
    farmer_name: "Tariq Mehmood",
    district: "Charsadda",
    region: "khyber_pakhtunkhwa",
    crop_type: "Wheat",
    crop_vital_score: 82,
    soil_moisture_pct: 70.2,
    ndvi_index: 0.78,
    coordinates: [34.1482, 71.7406],
    advisory_text_en: "Healthy wheat stand. No action needed for 3 days.",
    advisory_text_ur: "صحت مند گندم کی فصل۔ 3 دن تک کسی کارروائی کی ضرورت نہیں۔",
    last_updated: "2026-05-16",
    advisory_status: "Verified",
    ndvi_history: generateNdviHistory(0.78),
  },
  {
    field_id: "multan_plot_01",
    farmer_name: "Chaudhry Riaz",
    district: "Multan",
    region: "punjab",
    crop_type: "Cotton",
    crop_vital_score: 56,
    soil_moisture_pct: 48.3,
    ndvi_index: 0.54,
    coordinates: [30.1984, 71.4622],
    advisory_text_en: "Cotton showing moderate stress. Check for bollworm activity.",
    advisory_text_ur: "کپاس میں درمیانہ دباؤ۔ بول وریم کی سرگرمی چیک کریں۔",
    last_updated: "2026-05-18",
    advisory_status: "Sent",
    ndvi_history: generateNdviHistory(0.54),
  },
  {
    field_id: "multan_plot_02",
    farmer_name: "Malik Sikandar",
    district: "Multan",
    region: "punjab",
    crop_type: "Cotton",
    crop_vital_score: 33,
    soil_moisture_pct: 28.1,
    ndvi_index: 0.31,
    coordinates: [30.2200, 71.5000],
    advisory_text_en: "CRITICAL: Severe heat stress + water deficit. Flood irrigate within 12 hours.",
    advisory_text_ur: "انتباہ: شدید حرارت کا دباؤ + پانی کی کمی۔ 12 گھنٹے میں فلڈ آبپاشی کریں۔",
    last_updated: "2026-05-18",
    advisory_status: "Sent",
    ndvi_history: generateNdviHistory(0.31),
  },
  {
    field_id: "multan_plot_03",
    farmer_name: "Allah Ditta",
    district: "Multan",
    region: "punjab",
    crop_type: "Wheat",
    crop_vital_score: 79,
    soil_moisture_pct: 66.9,
    ndvi_index: 0.75,
    coordinates: [30.1800, 71.4400],
    advisory_text_en: "Wheat crop nearing harvest. Good yield expected.",
    advisory_text_ur: "گندم کی فصل کٹائی کے قریب ہے۔ اچھی پیداوار متوقع ہے۔",
    last_updated: "2026-05-17",
    advisory_status: "Verified",
    ndvi_history: generateNdviHistory(0.75),
  },
  {
    field_id: "multan_plot_04",
    farmer_name: "Ghulam Abbas",
    district: "Multan",
    region: "punjab",
    crop_type: "Cotton",
    crop_vital_score: 62,
    soil_moisture_pct: 52.0,
    ndvi_index: 0.59,
    coordinates: [30.2400, 71.5200],
    advisory_text_en: "Moderate cotton health. Apply recommended pesticide dose.",
    advisory_text_ur: "کپاس کی صحت درمیانی ہے۔ تجویز کردہ کیڑے مار ادویات لگائیں۔",
    last_updated: "2026-05-16",
    advisory_status: "Sent",
    ndvi_history: generateNdviHistory(0.59),
  },
  {
    field_id: "khanewal_plot_01",
    farmer_name: "Rana Asif",
    district: "Khanewal",
    region: "punjab",
    crop_type: "Cotton",
    crop_vital_score: 88,
    soil_moisture_pct: 74.1,
    ndvi_index: 0.84,
    coordinates: [30.3000, 71.9300],
    advisory_text_en: "Cotton crop thriving. Continue standard management.",
    advisory_text_ur: "کپاس کی فصل بہتر ہے۔ معیاری انتظام جاری رکھیں۔",
    last_updated: "2026-05-18",
    advisory_status: "Verified",
    ndvi_history: generateNdviHistory(0.84),
  },
  {
    field_id: "khanewal_plot_02",
    farmer_name: "Bashir Ahmad",
    district: "Khanewal",
    region: "punjab",
    crop_type: "Wheat",
    crop_vital_score: 41,
    soil_moisture_pct: 33.5,
    ndvi_index: 0.39,
    coordinates: [30.2800, 71.9100],
    advisory_text_en: "Wheat showing decline. Possible fungal infection — field visit recommended.",
    advisory_text_ur: "گندم میں کمی۔ ممکنہ فنگل انفیکشن — فیلڈ وزٹ کی سفارش۔",
    last_updated: "2026-05-17",
    advisory_status: "Flagged",
    ndvi_history: generateNdviHistory(0.39),
  },
  {
    field_id: "khanewal_plot_03",
    farmer_name: "Muhammad Iqbal",
    district: "Khanewal",
    region: "punjab",
    crop_type: "Cotton",
    crop_vital_score: 71,
    soil_moisture_pct: 60.8,
    ndvi_index: 0.68,
    coordinates: [30.3200, 71.9600],
    advisory_text_en: "Cotton health fair. Monitor for whitefly this week.",
    advisory_text_ur: "کپاس کی صعت ٹھیک ہے۔ اس ہفتے وائٹ فلائی کی نگرانی کریں۔",
    last_updated: "2026-05-15",
    advisory_status: "Sent",
    ndvi_history: generateNdviHistory(0.68),
  },
];

export const emergencyAlerts: EmergencyAlert[] = [
  {
    id: "alert_001",
    district: "Multan",
    message_en: "Heatwave Alert: Temperatures expected to exceed 48°C. Irrigate all crops within 12 hours.",
    message_ur: "ہیٹ ویو الرٹ: درجہ حرارت 48 ڈگری سے تجاوز کر سکتا ہے۔ 12 گھنٹے میں تمام فصلوں کو آبپاشی کریں۔",
    sent_at: "2026-05-17T08:30:00Z",
    recipient_count: 342,
    severity: "high",
  },
  {
    id: "alert_002",
    district: "Swat",
    message_en: "Heavy rainfall warning: Expected 80mm+ in next 48 hours. Ensure proper drainage.",
    message_ur: "بارش کا انتباہ: اگلے 48 گھنٹوں میں 80 ملی میٹر سے زیادہ بارش متوقع۔ مناسب نکاسی آب یقینی بنائیں۔",
    sent_at: "2026-05-16T14:00:00Z",
    recipient_count: 198,
    severity: "medium",
  },
  {
    id: "alert_003",
    district: "Mardan",
    message_en: "Locust swarm sighting reported near Takht-i-Bahi. Apply recommended pesticides immediately.",
    message_ur: "تخت بھائی کے قریب ٹڈی دل دیکھا گیا۔ فوری طور پر تجویز کردہ کیڑے مار ادویات لگائیں۔",
    sent_at: "2026-05-15T10:15:00Z",
    recipient_count: 276,
    severity: "high",
  },
];

export const districts = [
  "All Districts",
  "Mardan",
  "Swat",
  "Charsadda",
  "Peshawar",
  "Multan",
  "Khanewal",
] as const;

export const regions = [
  { value: "all", label: "All Pakistan" },
  { value: "khyber_pakhtunkhwa", label: "Khyber Pakhtunkhwa" },
  { value: "punjab", label: "Punjab" },
] as const;

/* ------------------------------------------------------------------ */
/* ML model & prediction mock data (mirrors backend API contracts)     */
/* ------------------------------------------------------------------ */

export const MODEL_VERSION = "crop_vital_rf_v2.1.0";

function scoreToClass(score: number): PredictionClass {
  if (score >= 75) return 0;
  if (score >= 45) return 1;
  return 2;
}

/** Deterministic pseudo-random in [min, max] seeded by field id hash */
function seeded(id: string, min: number, max: number): number {
  let h = 0;
  for (let i = 0; i < id.length; i++) h = (h * 31 + id.charCodeAt(i)) >>> 0;
  return min + ((h % 1000) / 1000) * (max - min);
}

function mockWeather(fieldId: string, district: string): WeatherData {
  const hot = district === "Multan" || district === "Khanewal";
  return {
    temperature_c: parseFloat(seeded(fieldId + "t", hot ? 34 : 24, hot ? 47 : 34).toFixed(1)),
    humidity_pct: parseFloat(seeded(fieldId + "h", 18, 78).toFixed(1)),
    precipitation_mm: parseFloat(seeded(fieldId + "p", 0, 14).toFixed(1)),
    wind_speed_kmh: parseFloat(seeded(fieldId + "w", 3, 28).toFixed(1)),
    solar_radiation: parseFloat(seeded(fieldId + "s", 14, 27).toFixed(1)),
    fetched_at: "2026-05-18T06:00:00Z",
    source: "NASA POWER",
  };
}

/** GET /api/admin/dashboard — farms with live ML vital scores */
export const dashboardFarms: DashboardFarm[] = farmRecords.map((f) => ({
  ...f,
  prediction_class: scoreToClass(f.crop_vital_score),
  confidence: parseFloat(seeded(f.field_id + "c", 0.78, 0.97).toFixed(2)),
  model_version: MODEL_VERSION,
  last_prediction_at: `${f.last_updated}T06:00:00Z`,
  weather: mockWeather(f.field_id, f.district),
}));

/** GET /api/admin/predictions — recent ML predictions timeline */
export const predictionHistory: PredictionRecord[] = dashboardFarms
  .flatMap((f, idx) => {
    const hoursAgo = idx * 5 + (idx % 3) * 2;
    const ts = new Date(Date.parse("2026-05-18T09:00:00Z") - hoursAgo * 3600 * 1000);
    return [
      {
        prediction_id: `pred_${idx.toString().padStart(3, "0")}`,
        field_id: f.field_id,
        farmer_name: f.farmer_name,
        district: f.district,
        crop_type: f.crop_type,
        crop_vital_score: f.crop_vital_score,
        prediction_class: f.prediction_class,
        confidence: f.confidence,
        model_version: f.model_version,
        timestamp: ts.toISOString(),
        trigger: "scheduled" as const,
        weather_inputs: {
          temperature_c: f.weather.temperature_c,
          humidity_pct: f.weather.humidity_pct,
          precipitation_mm: f.weather.precipitation_mm,
        },
      },
    ];
  })
  .sort((a, b) => b.timestamp.localeCompare(a.timestamp));

/** GET /api/admin/model-metrics — model card */
export const modelMetrics: ModelMetrics = {
  model_version: MODEL_VERSION,
  model_type: "Random Forest Classifier",
  accuracy: 0.954,
  f1_score: 0.948,
  precision: 0.951,
  recall: 0.946,
  confusion_matrix: [
    [156, 6, 2],
    [5, 142, 7],
    [3, 4, 118],
  ],
  feature_importance: [
    { feature: "Max Temperature (°C)", importance: 0.28 },
    { feature: "Humidity (%)", importance: 0.22 },
    { feature: "Precipitation (mm)", importance: 0.18 },
    { feature: "Solar Radiation", importance: 0.12 },
    { feature: "Wind Speed", importance: 0.08 },
    { feature: "Day of Year", importance: 0.07 },
    { feature: "District (encoded)", importance: 0.05 },
  ],
  trained_at: "2026-04-30",
  training_samples: 443,
  known_limitations: [
    "Predictions are weather-based proxy estimates, not field-validated observations",
    "soil_moisture_pct and ndvi_index are placeholder values until satellite data integration",
    "Trained on Mardan, Swat, and Multan district data — performance may vary elsewhere",
    "Pest and disease events are not detectable from weather data alone",
  ],
};

export { mockWeather, scoreToClass };
export const MODEL_DISCLAIMER =
  "Predictions are weather-based proxy estimates, not field-validated observations.";
