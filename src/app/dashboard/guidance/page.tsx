import { CheckCircle2, Circle, Clock } from "lucide-react";
import { Card } from "@/components/ui/card";

const timeline = [
  { stage: "Soil Preparation", desc: "Ploughing and adding baseline NPK", status: "completed", date: "Oct 15" },
  { stage: "Sowing", desc: "Planting wheat seeds at optimal depth", status: "completed", date: "Oct 25" },
  { stage: "First Irrigation", desc: "Crucial watering for early germination", status: "current", date: "Nov 15" },
  { stage: "Fertilizer Top Dressing", desc: "Adding urea for rapid growth", status: "upcoming", date: "Dec 10" },
  { stage: "Harvesting", desc: "Final crop collection", status: "upcoming", date: "Mar 20" }
];

export default function GuidancePage() {
  return (
    <div className="p-8 max-w-4xl">
      <div className="mb-8">
        <h1 className="text-3xl font-bold tracking-tight">Cultivation Guidance</h1>
        <p className="text-muted-foreground mt-1">Step-by-step timeline for your active Wheat crop</p>
      </div>

      <Card className="bg-card/40 border-white/5 p-8 relative overflow-hidden">
        <div className="absolute top-0 left-8 bottom-0 w-px bg-white/10" />
        
        <div className="space-y-8 relative z-10">
          {timeline.map((item, i) => (
            <div key={i} className="flex gap-6">
              <div className="bg-background relative">
                {item.status === "completed" && <CheckCircle2 className="text-primary mt-1" size={24} />}
                {item.status === "current" && <Clock className="text-amber-400 mt-1 animate-pulse" size={24} />}
                {item.status === "upcoming" && <Circle className="text-white/20 mt-1" size={24} />}
              </div>
              <div className={`flex-1 ${item.status === "upcoming" ? "opacity-50" : ""}`}>
                <div className="flex justify-between items-start">
                  <h3 className={`text-lg font-semibold ${item.status === "current" ? "text-amber-400" : ""}`}>
                    {item.stage}
                  </h3>
                  <span className="text-sm font-medium text-muted-foreground bg-white/5 px-2 py-1 rounded">{item.date}</span>
                </div>
                <p className="text-muted-foreground mt-1 text-sm">{item.desc}</p>
                
                {item.status === "current" && (
                  <div className="mt-4 p-4 rounded-lg bg-amber-400/10 border border-amber-400/20 text-amber-200/90 text-sm">
                    <strong>Action Required:</strong> Based on the recent dry weather, we recommend irrigating your field within the next 48 hours to prevent moisture stress.
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      </Card>
    </div>
  );
}
