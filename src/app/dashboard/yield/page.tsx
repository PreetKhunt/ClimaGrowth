"use client";

import { 
  AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip as RechartsTooltip, ResponsiveContainer,
  BarChart, Bar, Legend
} from "recharts";
import { Activity, ShieldCheck, AlertTriangle, Scale, Target, Sprout } from "lucide-react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

const yieldHistory = [
  { year: "2021", yield: 18, expected: 19 },
  { year: "2022", yield: 21, expected: 20 },
  { year: "2023", yield: 19, expected: 22 }, // Drought year
  { year: "2024", yield: 24, expected: 23 },
  { year: "2025", yield: 26, expected: 25 },
  { year: "2026", yield: null, expected: 28 }, // Current Prediction
];

const riskFactors = [
  { name: "Pest Infestation", level: 30, color: "#4CC9F0" },
  { name: "Water Scarcity", level: 15, color: "#00FF88" },
  { name: "Market Price Drop", level: 45, color: "#F72585" },
  { name: "Extreme Heat", level: 60, color: "#f59e0b" },
];

export default function YieldPredictionPage() {
  return (
    <div className="p-8 max-w-7xl mx-auto space-y-8">
      <div className="flex justify-between items-end">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">AI Yield Prediction</h1>
          <p className="text-muted-foreground mt-1">Predict your crop output using satellite imaging and historical data.</p>
        </div>
        <Button className="gap-2 bg-primary text-primary-foreground"><Target size={16} /> Recalibrate AI</Button>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card className="p-6 bg-card/40 border-white/5 relative overflow-hidden group">
          <h3 className="text-muted-foreground text-sm font-medium mb-4 flex items-center gap-2">
            <Sprout size={16} className="text-primary" /> Expected Yield
          </h3>
          <div className="text-4xl font-bold text-white mb-1">28<span className="text-lg text-muted-foreground ml-1">Quintals/Acre</span></div>
          <div className="text-xs text-primary font-medium">+8% from last year</div>
        </Card>
        
        <Card className="p-6 bg-card/40 border-white/5 relative overflow-hidden group">
          <h3 className="text-muted-foreground text-sm font-medium mb-4 flex items-center gap-2">
            <ShieldCheck size={16} className="text-blue-400" /> AI Confidence Score
          </h3>
          <div className="text-4xl font-bold text-blue-400 mb-1">94<span className="text-lg text-blue-400/50 ml-1">%</span></div>
          <div className="text-xs text-muted-foreground">Based on current weather models</div>
        </Card>

        <Card className="p-6 bg-card/40 border-white/5 relative overflow-hidden group">
          <h3 className="text-muted-foreground text-sm font-medium mb-4 flex items-center gap-2">
            <Scale size={16} className="text-amber-400" /> Estimated Revenue
          </h3>
          <div className="text-4xl font-bold text-amber-400 mb-1">₹61,600</div>
          <div className="text-xs text-muted-foreground">At current market rate (₹2,200/q)</div>
        </Card>

        <Card className="p-6 bg-card/40 border-white/5 relative overflow-hidden group">
          <h3 className="text-muted-foreground text-sm font-medium mb-4 flex items-center gap-2">
            <AlertTriangle size={16} className="text-rose-400" /> Overall Risk
          </h3>
          <div className="text-4xl font-bold text-rose-400 mb-1">Low</div>
          <div className="text-xs text-muted-foreground">Conditions are highly favorable</div>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Historical Yield Chart */}
        <Card className="lg:col-span-2 p-6 bg-card/40 border-white/5">
          <h3 className="text-lg font-bold mb-6">Historical vs Predicted Yield (Wheat)</h3>
          <div className="h-[300px] w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={yieldHistory}>
                <defs>
                  <linearGradient id="colorYield" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#00FF88" stopOpacity={0.5} />
                    <stop offset="95%" stopColor="#00FF88" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#ffffff10" vertical={false} />
                <XAxis dataKey="year" stroke="#ffffff50" axisLine={false} tickLine={false} />
                <YAxis stroke="#ffffff50" axisLine={false} tickLine={false} />
                <RechartsTooltip 
                  contentStyle={{ backgroundColor: "#050505", borderColor: "#ffffff20", borderRadius: "8px" }}
                  itemStyle={{ color: "#fff" }}
                />
                <Area type="monotone" dataKey="expected" stroke="#ffffff30" strokeDasharray="5 5" fill="none" strokeWidth={2} name="AI Prediction" />
                <Area type="monotone" dataKey="yield" stroke="#00FF88" strokeWidth={3} fillOpacity={1} fill="url(#colorYield)" name="Actual Yield" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </Card>

        {/* Risk Factors */}
        <Card className="p-6 bg-card/40 border-white/5">
          <h3 className="text-lg font-bold mb-6">Risk Factor Analysis</h3>
          <div className="space-y-6">
            {riskFactors.map(risk => (
              <div key={risk.name}>
                <div className="flex justify-between text-sm mb-2">
                  <span className="text-white font-medium">{risk.name}</span>
                  <span className="text-muted-foreground">{risk.level}%</span>
                </div>
                <div className="w-full h-2 rounded-full bg-black/40 overflow-hidden">
                  <div className="h-full rounded-full transition-all duration-1000" style={{ width: `${risk.level}%`, backgroundColor: risk.color }} />
                </div>
              </div>
            ))}
          </div>
          <div className="mt-8 p-4 bg-rose-500/10 border border-rose-500/20 rounded-xl">
            <div className="flex items-start gap-3">
              <AlertTriangle className="text-rose-400 shrink-0 mt-0.5" size={16} />
              <p className="text-sm text-rose-200"><strong>Heat Wave Warning:</strong> Temperatures are expected to spike next week. Ensure irrigation is active to prevent crop stress.</p>
            </div>
          </div>
        </Card>
      </div>
    </div>
  );
}
