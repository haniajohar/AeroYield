import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function getVitalStatus(score: number) {
  if (score >= 75) return { label: "Healthy", color: "green" as const };
  if (score >= 45) return { label: "Moderate Stress", color: "amber" as const };
  return { label: "Critical", color: "red" as const };
}

export function formatDate(dateStr: string) {
  return new Date(dateStr).toLocaleDateString("en-PK", {
    year: "numeric",
    month: "short",
    day: "numeric",
  });
}
