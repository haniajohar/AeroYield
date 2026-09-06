import { Activity, BrainCircuit, AlertTriangle, Layers } from "lucide-react";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Cell,
} from "recharts";
import type { ModelMetrics } from "../types";
import { classLabel } from "../types";
import { cn } from "../lib/utils";
import { DisclaimerBanner } from "./DisclaimerBanner";

interface ModelHealthProps {
  metrics: ModelMetrics | null;
}

function pct(v: number) {
  return `${(v * 100).toFixed(1)}%`;
}

export function ModelHealth({ metrics }: ModelHealthProps) {
  if (!metrics) {
    return (
      <p className="rounded-xl border border-border bg-card p-8 text-center text-muted-foreground">
        Model metrics unavailable.
      </p>
    );
  }

  const classColors = ["#22c55e", "#f59e0b", "#ef4444"];
  const classes = [0, 1, 2] as const;
  const maxCell = Math.max(...metrics.confusion_matrix.flat());

  const scoreCards = [
    { label: "Accuracy", value: metrics.accuracy },
    { label: "F1 Score", value: metrics.f1_score },
    { label: "Precision", value: metrics.precision },
    { label: "Recall", value: metrics.recall },
  ];

  return (
    <div className="space-y-6">
      <DisclaimerBanner />

      {/* Header card */}
      <div className="rounded-xl border border-border bg-card p-4">
        <div className="flex flex-wrap items-center gap-3">
          <div className="flex h-11 w-11 items-center justify-center rounded-lg bg-primary/10">
            <BrainCircuit className="h-6 w-6 text-primary" />
          </div>
          <div>
            <h3 className="font-semibold text-foreground">{metrics.model_version}</h3>
            <p className="text-xs text-muted-foreground">
              {metrics.model_type} · trained {metrics.trained_at} on{" "}
              {metrics.training_samples} samples
            </p>
          </div>
          <span className="ml-auto text-xs text-muted-foreground">
            GET /api/admin/model-metrics
          </span>
        </div>
      </div>

      {/* Score cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {scoreCards.map((c) => (
          <div
            key={c.label}
            className="rounded-xl border border-border bg-card p-4 flex items-center gap-3"
          >
            <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-emerald-500/10">
              <Activity className="h-5 w-5 text-emerald-500" />
            </div>
            <div>
              <p className="text-xs text-muted-foreground uppercase tracking-wider">
                {c.label}
              </p>
              <p className="text-xl font-black text-foreground">{pct(c.value)}</p>
            </div>
          </div>
        ))}
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        {/* Feature importance */}
        <div className="rounded-xl border border-border bg-card p-4">
          <div className="flex items-center gap-2 mb-4">
            <Layers className="h-5 w-5 text-primary" />
            <h4 className="font-semibold text-foreground">Feature Importance</h4>
          </div>
          <div className="h-72">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart
                data={metrics.feature_importance}
                layout="vertical"
                margin={{ left: 8, right: 16 }}
              >
                <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" horizontal={false} />
                <XAxis
                  type="number"
                  domain={[0, 0.3]}
                  tickFormatter={(v: number) => `${Math.round(v * 100)}%`}
                  tick={{ fontSize: 11, fill: "hsl(var(--muted-foreground))" }}
                />
                <YAxis
                  type="category"
                  dataKey="feature"
                  width={130}
                  tick={{ fontSize: 11, fill: "hsl(var(--muted-foreground))" }}
                />
                <Tooltip
                  formatter={(v) => [`${(Number(v) * 100).toFixed(1)}%`, "Importance"] as [string, string]}
                  contentStyle={{
                    backgroundColor: "hsl(var(--card))",
                    border: "1px solid hsl(var(--border))",
                    borderRadius: "8px",
                    fontSize: "12px",
                  }}
                />
                <Bar dataKey="importance" radius={[0, 4, 4, 0]}>
                  {metrics.feature_importance.map((_, i) => (
                    <Cell key={i} fill="#22c55e" fillOpacity={1 - i * 0.09} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Confusion matrix */}
        <div className="rounded-xl border border-border bg-card p-4">
          <div className="flex items-center gap-2 mb-4">
            <Layers className="h-5 w-5 text-primary" />
            <h4 className="font-semibold text-foreground">Confusion Matrix</h4>
            <span className="text-xs text-muted-foreground">rows = true class</span>
          </div>
          <div className="overflow-x-auto">
            <table className="text-sm">
              <thead>
                <tr>
                  <th className="p-2" />
                  {classes.map((c) => (
                    <th key={c} className="p-2 text-xs font-semibold text-muted-foreground">
                      Pred {c} · {classLabel(c)}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {metrics.confusion_matrix.map((row, trueIdx) => (
                  <tr key={trueIdx}>
                    <th className="p-2 text-right text-xs font-semibold text-muted-foreground whitespace-nowrap">
                      True {trueIdx} · {classLabel(classes[trueIdx])}
                    </th>
                    {row.map((cell, predIdx) => (
                      <td key={predIdx} className="p-1.5">
                        <div
                          className={cn(
                            "flex h-14 w-24 items-center justify-center rounded-lg font-bold text-sm",
                            trueIdx === predIdx ? "text-white" : "text-foreground"
                          )}
                          style={{
                            backgroundColor:
                              trueIdx === predIdx
                                ? classColors[trueIdx]
                                : `hsl(var(--muted))`,
                            opacity:
                              trueIdx === predIdx
                                ? 0.35 + (cell / maxCell) * 0.65
                                : 1,
                          }}
                        >
                          {cell}
                        </div>
                      </td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <p className="mt-3 text-xs text-muted-foreground">
            Diagonal cells are correct predictions. Off-diagonal shows misclassifications.
          </p>
        </div>
      </div>

      {/* Known limitations */}
      <div className="rounded-xl border border-border bg-card p-4">
        <div className="flex items-center gap-2 mb-3">
          <AlertTriangle className="h-5 w-5 text-amber-500" />
          <h4 className="font-semibold text-foreground">Known Limitations</h4>
          <span className="text-xs text-muted-foreground">
            from crop_vital_model_metadata.json
          </span>
        </div>
        <ul className="space-y-2">
          {metrics.known_limitations.map((l, i) => (
            <li key={i} className="flex items-start gap-2 text-sm text-foreground">
              <span className="mt-1.5 h-1.5 w-1.5 shrink-0 rounded-full bg-amber-500" />
              {l}
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}
