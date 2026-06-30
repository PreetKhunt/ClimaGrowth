/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable react/no-unescaped-entities */
/* eslint-disable @typescript-eslint/no-unused-vars */
/* eslint-disable @typescript-eslint/no-require-imports */
 
 
 
/* eslint-disable @typescript-eslint/no-unused-vars */
 
"use client";

import { useState, useEffect } from "react";
import { 
  AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip as RechartsTooltip, ResponsiveContainer,
  BarChart, Bar, Legend
} from "recharts";
import { Activity, ShieldCheck, AlertTriangle, Scale, Target, Sprout, Loader2 } from "lucide-react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { fetchFarms } from "@/actions/farm-actions";
import { generateYieldPrediction, fetchLatestYieldPrediction } from "@/actions/yield-actions";

export default function YieldPredictionPage() {
  const [farms, setFarms] = useState<any[]>([]);
  const [selectedFarmId, setSelectedFarmId] = useState<string | null>(null);
  const [prediction, setPrediction] = useState<any>(null);
  const [isRecalibrating, setIsRecalibrating] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadData() {
      setLoading(true);
      const farmsRes = await fetchFarms();
      if (farmsRes.success && farmsRes.data && farmsRes.data.length > 0) {
        setFarms(farmsRes.data);
        setSelectedFarmId(farmsRes.data[0].id);
        
        const predRes = await fetchLatestYieldPrediction(farmsRes.data[0].id);
        if (predRes.success && predRes.data) {
          setPrediction(predRes.data);
        }
      }
      setLoading(false);
    }
    loadData();
  }, []);

  const handleRecalibrate = async () => {
    if (!selectedFarmId) return;
    setIsRecalibrating(true);
    try {
      const res = await generateYieldPrediction(selectedFarmId);
      if (!res.success) throw new Error(res.error);
      setPrediction(res.data);
    } catch (err: any) {
      alert(err.message || 'Failed to recalibrate AI.');
    } finally {
      setIsRecalibrating(false);
    }
  };

  const yieldHistory = [
    { year: "2021", yield: 18, expected: 19 },
    { year: "2022", yield: 21, expected: 20 },
    { year: "2023", yield: 19, expected: 22 }, // Drought year
    { year: "2024", yield: 24, expected: 23 },
    { year: "2025", yield: 26, expected: 25 },
    { year: "2026", yield: null, expected: prediction?.expected_yield_tons || 28 }, 
  ];

  if (loading) {
    return <div className="p-8 flex justify-center"><Loader2 className="animate-spin text-primary w-8 h-8" /></div>;
  }

  if (farms.length === 0) {
    return (
      <div className="p-8 max-w-7xl mx-auto space-y-8 text-center">
        <h1 className="text-3xl font-bold tracking-tight">AI Yield Prediction</h1>
        <p className="text-muted-foreground mt-4">You need to add a farm first before AI can predict yields.</p>
      </div>
    );
  }

  return (
    <div className="p-8 max-w-7xl mx-auto space-y-8">
      <div className="flex justify-between items-end">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">AI Yield Prediction</h1>
          <p className="text-muted-foreground mt-1">Predict your crop output using satellite imaging and historical data.</p>
        </div>
        
        <div className="flex items-center gap-4">
          <select 
            className="bg-black/40 border border-white/10 rounded-md p-2 text-sm text-white"
            value={selectedFarmId || ""}
            onChange={(e) => setSelectedFarmId(e.target.value)}
          >
            {farms.map(f => <option key={f.id} value={f.id}>{f.name}</option>)}
          </select>
          <Button onClick={handleRecalibrate} disabled={isRecalibrating} className="gap-2 bg-primary text-primary-foreground">
            {isRecalibrating ? <Loader2 className="animate-spin w-4 h-4" /> : <Target size={16} />}
            Recalibrate AI
          </Button>
        </div>
      </div>

      {prediction ? (
        <>
          {/* KPI Cards */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <Card className="p-6 bg-card/40 border-white/5 relative overflow-hidden group">
              <h3 className="text-muted-foreground text-sm font-medium mb-4 flex items-center gap-2">
                <Sprout size={16} className="text-primary" /> Expected Yield
              </h3>
              <div className="text-4xl font-bold text-white mb-1">{prediction.expected_yield_tons}<span className="text-lg text-muted-foreground ml-1">Tons</span></div>
            </Card>
            
            <Card className="p-6 bg-card/40 border-white/5 relative overflow-hidden group">
              <h3 className="text-muted-foreground text-sm font-medium mb-4 flex items-center gap-2">
                <ShieldCheck size={16} className="text-blue-400" /> AI Confidence Score
              </h3>
              <div className="text-4xl font-bold text-blue-400 mb-1">94<span className="text-lg text-blue-400/50 ml-1">%</span></div>
            </Card>

            <Card className="p-6 bg-card/40 border-white/5 relative overflow-hidden group">
              <h3 className="text-muted-foreground text-sm font-medium mb-4 flex items-center gap-2">
                <Scale size={16} className="text-amber-400" /> Estimated Profit
              </h3>
              <div className="text-4xl font-bold text-amber-400 mb-1">₹{(prediction.estimated_profit || 0).toLocaleString()}</div>
            </Card>

            <Card className="p-6 bg-card/40 border-white/5 relative overflow-hidden group">
              <h3 className="text-muted-foreground text-sm font-medium mb-4 flex items-center gap-2">
                <AlertTriangle size={16} className={prediction.risk_level === 'High' ? 'text-rose-400' : 'text-green-400'} /> Overall Risk
              </h3>
              <div className={`text-4xl font-bold mb-1 ${prediction.risk_level === 'High' ? 'text-rose-400' : 'text-green-400'}`}>{prediction.risk_level}</div>
            </Card>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            {/* Historical Yield Chart */}
            <Card className="lg:col-span-2 p-6 bg-card/40 border-white/5">
              <h3 className="text-lg font-bold mb-6">Historical vs Predicted Yield</h3>
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

            {/* AI Explanation & Improvements */}
            <Card className="p-6 bg-card/40 border-white/5">
              <h3 className="text-lg font-bold mb-6">AI Agronomist Insights</h3>
              <div className="text-sm text-muted-foreground mb-6">
                {prediction.ai_explanation}
              </div>
              
              <h4 className="font-semibold text-white mb-4 text-sm">Recommended Improvements:</h4>
              <ul className="space-y-3">
                {prediction.recommended_improvements?.map((imp: string, i: number) => (
                  <li key={i} className="flex gap-2 text-sm text-muted-foreground">
                    <span className="text-primary mt-1">•</span> {imp}
                  </li>
                ))}
              </ul>
            </Card>
          </div>
        </>
      ) : (
        <Card className="p-12 bg-card/40 border-white/5 flex flex-col items-center justify-center text-center">
          <Target size={48} className="text-muted-foreground mb-4" />
          <h3 className="text-xl font-bold mb-2">No Prediction Generated</h3>
          <p className="text-muted-foreground mb-6 max-w-md">Click 'Recalibrate AI' to generate a yield prediction for this farm.</p>
          <Button onClick={handleRecalibrate} disabled={isRecalibrating} className="bg-primary text-primary-foreground gap-2">
            {isRecalibrating ? <Loader2 className="animate-spin w-4 h-4" /> : <Target size={16} />} 
            Recalibrate AI
          </Button>
        </Card>
      )}
    </div>
  );
}
