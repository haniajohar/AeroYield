import { useState } from "react";
import {
  Megaphone,
  Send,
  AlertTriangle,
  Clock,
  MapPin,
  Users,
  CheckCircle2,
} from "lucide-react";
import { districts } from "../data/mockAdminData";
import type { EmergencyAlert } from "../types";
import { cn } from "../lib/utils";

interface EmergencyBroadcastProps {
  alerts: EmergencyAlert[];
  onSend: (district: string, messageEn: string, messageUr: string) => void;
}

const templates = [
  {
    label: "Heatwave Alert",
    en: "Heatwave Alert: Temperatures expected to exceed {temp}°C. Irrigate all crops within {hours} hours to prevent heat stress damage.",
    ur: "ہیٹ ویو الرٹ: درجہ حرارت {temp} ڈگری سے تجاوز کر سکتا ہے۔ حرارت کے نقصان سے بچنے کے لیے {hours} گھنٹے میں تمام فصلوں کو آبپاشی کریں۔",
  },
  {
    label: "Pest Outbreak",
    en: "Pest Alert: {pest} infestation reported in your district. Apply recommended pesticide immediately. Contact your nearest field officer for assistance.",
    ur: "کیڑوں کا انتباہ: آپ کے ضلع میں {pest} کا حملہ رپورٹ ہوا ہے۔ فوری طور پر تجویز کردہ کیڑے مار ادویات لگائیں۔ مدد کے لیے قریبی فیلڈ افسر سے رابطہ کریں۔",
  },
  {
    label: "Flood Warning",
    en: "Flood Warning: Heavy rainfall expected in next {hours} hours. Move livestock to higher ground and ensure proper field drainage.",
    ur: "سیلاب کا انتباہ: اگلے {hours} گھنٹوں میں شدید بارش متوقع ہے۔ مویشیوں کو اونچی جگہ منتقل کریں اور کھیتوں کی مناسب نکاسی آب یقینی بنائیں۔",
  },
];

export function EmergencyBroadcast({ alerts, onSend }: EmergencyBroadcastProps) {
  const [district, setDistrict] = useState("");
  const [template, setTemplate] = useState(0);
  const [messageEn, setMessageEn] = useState(templates[0].en);
  const [messageUr, setMessageUr] = useState(templates[0].ur);
  const [sent, setSent] = useState(false);

  const handleTemplateChange = (idx: number) => {
    setTemplate(idx);
    setMessageEn(templates[idx].en);
    setMessageUr(templates[idx].ur);
  };

  const handleSend = () => {
    if (!district || !messageEn) return;
    onSend(district, messageEn, messageUr);
    setSent(true);
    setTimeout(() => setSent(false), 3000);
    setDistrict("");
  };

  return (
    <div className="grid gap-6 lg:grid-cols-2">
      {/* Broadcast Form */}
      <div className="rounded-xl border border-border bg-card overflow-hidden">
        <div className="flex items-center gap-2 border-b border-border p-4">
          <Megaphone className="h-5 w-5 text-destructive" />
          <h3 className="font-semibold text-foreground">Emergency Broadcast</h3>
        </div>

        <div className="p-4 space-y-4">
          {/* District Selector */}
          <div>
            <label className="block text-xs font-medium text-muted-foreground mb-1.5">
              Target District
            </label>
            <div className="relative">
              <MapPin className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
              <select
                value={district}
                onChange={(e) => setDistrict(e.target.value)}
                className="w-full rounded-lg border border-input bg-background pl-9 pr-3 py-2.5 text-sm text-foreground focus:outline-none focus:ring-2 focus:ring-ring"
              >
                <option value="">Select district...</option>
                {districts
                  .filter((d) => d !== "All Districts")
                  .map((d) => (
                    <option key={d} value={d}>
                      {d}
                    </option>
                  ))}
              </select>
            </div>
          </div>

          {/* Template Selector */}
          <div>
            <label className="block text-xs font-medium text-muted-foreground mb-1.5">
              Message Template
            </label>
            <select
              value={template}
              onChange={(e) => handleTemplateChange(Number(e.target.value))}
              className="w-full rounded-lg border border-input bg-background px-3 py-2.5 text-sm text-foreground focus:outline-none focus:ring-2 focus:ring-ring"
            >
              {templates.map((t, i) => (
                <option key={i} value={i}>
                  {t.label}
                </option>
              ))}
            </select>
          </div>

          {/* English Message */}
          <div>
            <label className="block text-xs font-medium text-muted-foreground mb-1.5">
              English Message
            </label>
            <textarea
              value={messageEn}
              onChange={(e) => setMessageEn(e.target.value)}
              rows={3}
              className="w-full rounded-lg border border-input bg-background px-3 py-2.5 text-sm text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring resize-none"
            />
          </div>

          {/* Urdu Message */}
          <div>
            <label className="block text-xs font-medium text-muted-foreground mb-1.5">
              اردو پیغام (Urdu Message)
            </label>
            <textarea
              value={messageUr}
              onChange={(e) => setMessageUr(e.target.value)}
              rows={3}
              dir="rtl"
              className="w-full rounded-lg border border-input bg-background px-3 py-2.5 text-sm text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring resize-none text-right"
            />
          </div>

          {/* Send Button */}
          <button
            onClick={handleSend}
            disabled={!district || !messageEn || sent}
            className={cn(
              "w-full inline-flex items-center justify-center gap-2 rounded-lg px-4 py-2.5 text-sm font-semibold transition-all",
              sent
                ? "bg-emerald-500 text-white"
                : "bg-destructive text-destructive-foreground hover:bg-destructive/90 disabled:opacity-50 disabled:cursor-not-allowed"
            )}
          >
            {sent ? (
              <>
                <CheckCircle2 className="h-4 w-4" />
                Alert Broadcast Successfully
              </>
            ) : (
              <>
                <Send className="h-4 w-4" />
                Send Emergency Alert
              </>
            )}
          </button>
        </div>
      </div>

      {/* Alert History */}
      <div className="rounded-xl border border-border bg-card overflow-hidden">
        <div className="flex items-center gap-2 border-b border-border p-4">
          <Clock className="h-5 w-5 text-warning" />
          <h3 className="font-semibold text-foreground">Recent Alerts</h3>
        </div>
        <div className="divide-y divide-border max-h-[520px] overflow-y-auto">
          {alerts.map((alert) => (
            <div key={alert.id} className="p-4 hover:bg-muted/20 transition-colors">
              <div className="flex items-start justify-between gap-3">
                <div className="flex items-start gap-3 min-w-0">
                  <div
                    className={cn(
                      "mt-0.5 flex h-8 w-8 items-center justify-center rounded-lg shrink-0",
                      alert.severity === "high" && "bg-red-500/10",
                      alert.severity === "medium" && "bg-amber-500/10",
                      alert.severity === "low" && "bg-blue-500/10"
                    )}
                  >
                    <AlertTriangle
                      className={cn(
                        "h-4 w-4",
                        alert.severity === "high" && "text-red-500",
                        alert.severity === "medium" && "text-amber-500",
                        alert.severity === "low" && "text-blue-500"
                      )}
                    />
                  </div>
                  <div className="min-w-0">
                    <p className="text-sm font-medium text-foreground">{alert.message_en}</p>
                    <p className="text-xs text-muted-foreground mt-1" dir="rtl">
                      {alert.message_ur}
                    </p>
                    <div className="flex items-center gap-3 mt-2">
                      <span className="inline-flex items-center gap-1 text-xs text-muted-foreground">
                        <MapPin className="h-3 w-3" />
                        {alert.district}
                      </span>
                      <span className="inline-flex items-center gap-1 text-xs text-muted-foreground">
                        <Users className="h-3 w-3" />
                        {alert.recipient_count} recipients
                      </span>
                      <span className="inline-flex items-center gap-1 text-xs text-muted-foreground">
                        <Clock className="h-3 w-3" />
                        {new Date(alert.sent_at).toLocaleDateString("en-PK", {
                          month: "short",
                          day: "numeric",
                          hour: "2-digit",
                          minute: "2-digit",
                        })}
                      </span>
                    </div>
                  </div>
                </div>
                <span
                  className={cn(
                    "shrink-0 inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium",
                    alert.severity === "high" && "bg-red-500/10 text-red-500",
                    alert.severity === "medium" && "bg-amber-500/10 text-amber-500",
                    alert.severity === "low" && "bg-blue-500/10 text-blue-500"
                  )}
                >
                  {alert.severity}
                </span>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
