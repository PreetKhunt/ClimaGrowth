"use client";

import { Droplets, Sprout, TestTube, Activity } from "lucide-react";
import { Card } from "@/components/ui/card";
import { RadialBarChart, RadialBar, ResponsiveContainer, PolarAngleAxis } from "recharts";

const npkData = [
  { name: "Nitrogen", value: 45, fill: "#00FF88" },
  { name: "Phosphorus", value: 30, fill: "#4CC9F0" },
  { name: "Potassium", value: 70, fill: "#7B61FF" },
];

export default function SoilAnalytics() {
  return (
    <div className="p-8 max-w-6xl">
      <div className="mb-8 flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Soil Analytics</h1>
          <p className="text-muted-foreground mt-1">Comprehensive nutrient and health insights</p>
        </div>
        <div className="bg-primary/10 text-primary px-4 py-2 rounded-lg font-medium inline-flex items-center gap-2 w-fit">
          <TestTube size={20} />
          <span>Last Tested: 2 Days Ago</span>
        </div>
      </div>

      <div className="grid gap-6 md:grid-cols-3 mb-8">
        <Card className="col-span-1 bg-card/40 border-white/5 p-6 flex flex-col items-center justify-center text-center">
          <h3 className="text-lg font-semibold mb-2">Overall Soil Health</h3>
          <div className="relative w-40 h-40 flex items-center justify-center">
            <ResponsiveContainer width="100%" height="100%">
              <RadialBarChart 
                cx="50%" 
                cy="50%" 
                innerRadius="80%" 
                outerRadius="100%" 
                barSize={10} 
                data={[{ name: "Health", value: 87, fill: "#00FF88" }]} 
                startAngle={90} 
                endAngle={-270}
              >
                <PolarAngleAxis type="number" domain={[0, 100]} angleAxisId={0} tick={false} />
                <RadialBar background dataKey="value" cornerRadius={10} />
              </RadialBarChart>
            </ResponsiveContainer>
            <div className="absolute flex flex-col items-center justify-center">
              <span className="text-3xl font-bold text-primary">87</span>
              <span className="text-xs text-muted-foreground uppercase tracking-widest">Score</span>
            </div>
          </div>
          <p className="mt-4 text-sm text-muted-foreground">Optimal conditions for Wheat.</p>
        </Card>

        <Card className="col-span-1 md:col-span-2 bg-card/40 border-white/5 p-6">
          <h3 className="text-lg font-semibold mb-4">NPK Nutrient Levels</h3>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 h-full pb-8">
            <div className="flex flex-col items-center justify-center">
              <div className="w-full flex justify-between text-sm mb-2">
                <span className="font-medium text-[#00FF88]">Nitrogen (N)</span>
                <span>45 mg/kg</span>
              </div>
              <div className="w-full h-3 bg-white/10 rounded-full overflow-hidden">
                <div className="h-full bg-[#00FF88] rounded-full" style={{ width: '45%' }}></div>
              </div>
              <p className="text-xs text-muted-foreground mt-2 text-center">Slightly Low. Consider adding Urea.</p>
            </div>
            
            <div className="flex flex-col items-center justify-center">
              <div className="w-full flex justify-between text-sm mb-2">
                <span className="font-medium text-[#4CC9F0]">Phosphorus (P)</span>
                <span>30 mg/kg</span>
              </div>
              <div className="w-full h-3 bg-white/10 rounded-full overflow-hidden">
                <div className="h-full bg-[#4CC9F0] rounded-full" style={{ width: '30%' }}></div>
              </div>
              <p className="text-xs text-muted-foreground mt-2 text-center">Optimal level maintained.</p>
            </div>

            <div className="flex flex-col items-center justify-center">
              <div className="w-full flex justify-between text-sm mb-2">
                <span className="font-medium text-[#7B61FF]">Potassium (K)</span>
                <span>70 mg/kg</span>
              </div>
              <div className="w-full h-3 bg-white/10 rounded-full overflow-hidden">
                <div className="h-full bg-[#7B61FF] rounded-full" style={{ width: '70%' }}></div>
              </div>
              <p className="text-xs text-muted-foreground mt-2 text-center">High. Avoid K-rich fertilizers.</p>
            </div>
          </div>
        </Card>
      </div>

      <h3 className="text-xl font-semibold mb-4">Physical Properties</h3>
      <div className="grid gap-6 md:grid-cols-3">
        <Card className="bg-card/40 border-white/5 p-6 flex flex-col items-center justify-center text-center">
          <Droplets className="text-blue-400 mb-3" size={32} />
          <div className="text-sm font-medium text-muted-foreground">Moisture Content</div>
          <div className="text-2xl font-bold mt-1">32%</div>
        </Card>
        <Card className="bg-card/40 border-white/5 p-6 flex flex-col items-center justify-center text-center">
          <Activity className="text-rose-400 mb-3" size={32} />
          <div className="text-sm font-medium text-muted-foreground">Soil pH</div>
          <div className="text-2xl font-bold mt-1">6.5</div>
        </Card>
        <Card className="bg-card/40 border-white/5 p-6 flex flex-col items-center justify-center text-center">
          <Sprout className="text-green-400 mb-3" size={32} />
          <div className="text-sm font-medium text-muted-foreground">Organic Matter</div>
          <div className="text-2xl font-bold mt-1">4.2%</div>
        </Card>
      </div>
    </div>
  );
}
