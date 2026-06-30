/* eslint-disable @typescript-eslint/no-explicit-any */
 
 
 
 
"use client";

import { useState } from "react";
import { Calculator, Droplets, Leaf, IndianRupee, PieChart, Map, HelpCircle, ArrowLeft } from "lucide-react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

const tools = [
  { id: "water", name: "Water Requirement", icon: Droplets, color: "text-blue-400", bg: "bg-blue-400/20", desc: "Calculate exact irrigation needs based on crop, soil, and weather." },
  { id: "fertilizer", name: "Fertilizer Optimizer", icon: Leaf, color: "text-green-400", bg: "bg-green-400/20", desc: "Determine optimal NPK mixes for your specific farm parameters." },
  { id: "profit", name: "Profit Forecaster", icon: IndianRupee, color: "text-amber-400", bg: "bg-amber-400/20", desc: "Estimate yield revenue minus input costs based on live market rates." },
  { id: "emi", name: "Tractor/Loan EMI", icon: Calculator, color: "text-purple-400", bg: "bg-purple-400/20", desc: "Plan your agricultural machinery or land loans easily." },
  { id: "area", name: "Area Converter", icon: Map, color: "text-rose-400", bg: "bg-rose-400/20", desc: "Convert between Acres, Hectares, Bigha, and Guntha seamlessly." },
  { id: "seeds", name: "Seed Rate Calculator", icon: PieChart, color: "text-teal-400", bg: "bg-teal-400/20", desc: "Find the exact amount of seeds needed per acre for max yield." },
];

export default function SmartToolsPage() {
  const [activeTool, setActiveTool] = useState<string | null>(null);
  
  // Shared state for all calculators
  const [crop, setCrop] = useState("Wheat");
  const [area, setArea] = useState("1");
  const [loanAmount, setLoanAmount] = useState("500000");
  const [interestRate, setInterestRate] = useState("8.5");
  const [tenure, setTenure] = useState("5");
  
  const [result, setResult] = useState<any>(null);

  const calculateResult = () => {
    const areaNum = parseFloat(area) || 1;
    
    switch (activeTool) {
      case "water":
        // Base water req per acre in liters (approximate for demonstration)
        const waterPerAcre = crop === "Wheat" ? 450000 : crop === "Cotton" ? 700000 : 900000;
        setResult({
          title: "Total Water Required",
          value: `${(waterPerAcre * areaNum).toLocaleString()} Liters`,
          note: `Estimated for ${areaNum} acres of ${crop} during current season.`
        });
        break;

      case "fertilizer":
        // NPK bags per acre (50kg bags)
        const npk = crop === "Wheat" ? { urea: 2.5, dap: 1.5, mop: 0.5 } : 
                    crop === "Cotton" ? { urea: 3.5, dap: 2, mop: 1 } : 
                    { urea: 3, dap: 1.5, mop: 1 };
        
        setResult({
          title: "Fertilizer Recommendation",
          value: `Urea: ${Math.ceil(npk.urea * areaNum)} bags | DAP: ${Math.ceil(npk.dap * areaNum)} bags | MOP: ${Math.ceil(npk.mop * areaNum)} bags`,
          note: `Based on standard 50kg bags for ${areaNum} acres of ${crop}.`
        });
        break;

      case "profit":
        const yieldPerAcre = crop === "Wheat" ? 20 : crop === "Cotton" ? 12 : 25; // in Quintals
        const pricePerQuintal = crop === "Wheat" ? 2200 : crop === "Cotton" ? 6800 : 2500;
        const costPerAcre = crop === "Wheat" ? 15000 : crop === "Cotton" ? 25000 : 18000;
        
        const totalRevenue = (yieldPerAcre * areaNum) * pricePerQuintal;
        const totalCost = costPerAcre * areaNum;
        const profit = totalRevenue - totalCost;
        
        setResult({
          title: "Estimated Profit",
          value: `₹${profit.toLocaleString()}`,
          note: `Revenue: ₹${totalRevenue.toLocaleString()} | Input Costs: ₹${totalCost.toLocaleString()}`
        });
        break;

      case "emi":
        const p = parseFloat(loanAmount);
        const r = parseFloat(interestRate) / 12 / 100;
        const n = parseFloat(tenure) * 12;
        const emi = (p * r * Math.pow(1 + r, n)) / (Math.pow(1 + r, n) - 1);
        
        setResult({
          title: "Monthly EMI",
          value: `₹${Math.round(emi).toLocaleString()}`,
          note: `Total Interest: ₹${Math.round((emi * n) - p).toLocaleString()}`
        });
        break;

      case "area":
        setResult({
          title: "Area Equivalents",
          value: `${(areaNum * 0.404686).toFixed(2)} Hectares`,
          note: `${(areaNum * 2.5).toFixed(2)} Bigha | ${(areaNum * 40).toFixed(2)} Guntha`
        });
        break;
        
      case "seeds":
        const seedPerAcre = crop === "Wheat" ? 40 : crop === "Cotton" ? 2 : 10; // kg
        setResult({
          title: "Total Seed Required",
          value: `${(seedPerAcre * areaNum).toFixed(1)} KG`,
          note: `Optimal density for ${crop} is ${seedPerAcre}kg per acre.`
        });
        break;
    }
  };

  const handleToolSelect = (id: string) => {
    setActiveTool(id);
    setResult(null); // Reset result when switching tools
  };

  return (
    <div className="p-8 max-w-6xl">
      <div className="mb-8">
        <h1 className="text-3xl font-bold tracking-tight">Smart Tools</h1>
        <p className="text-muted-foreground mt-1">Suite of intelligent calculators for precision farming</p>
      </div>

      {!activeTool ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {tools.map(tool => (
            <Card 
              key={tool.id} 
              className="bg-card/40 border-white/5 p-6 cursor-pointer hover:bg-card/60 transition-colors group relative overflow-hidden"
              onClick={() => handleToolSelect(tool.id)}
            >
              <div className={`w-12 h-12 rounded-xl flex items-center justify-center mb-4 ${tool.bg} ${tool.color}`}>
                <tool.icon size={24} />
              </div>
              <h3 className="text-lg font-semibold mb-2 group-hover:text-primary transition-colors">{tool.name}</h3>
              <p className="text-sm text-muted-foreground">{tool.desc}</p>
            </Card>
          ))}
        </div>
      ) : (
        <div className="bg-card/40 border border-white/5 rounded-xl p-8 max-w-2xl mx-auto">
          <div className="flex justify-between items-center mb-6 border-b border-white/5 pb-4">
            <h2 className="text-2xl font-bold flex items-center gap-3">
              {tools.find(t => t.id === activeTool)?.name}
            </h2>
            <Button variant="ghost" size="sm" onClick={() => setActiveTool(null)} className="gap-2">
              <ArrowLeft size={16} /> Back
            </Button>
          </div>
          
          <div className="space-y-6">
            <div className="p-4 border border-white/10 rounded-lg bg-background/50 flex items-start gap-3">
              <HelpCircle className="text-primary mt-0.5 shrink-0" size={18} />
              <p className="text-sm text-muted-foreground">
                {tools.find(t => t.id === activeTool)?.desc} Enter your parameters below to generate an exact calculation.
              </p>
            </div>
            
            {activeTool === "emi" ? (
              <div className="grid gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Loan Amount (₹)</label>
                  <input type="number" value={loanAmount} onChange={e => setLoanAmount(e.target.value)} className="w-full border border-white/10 rounded-md px-3 py-2 text-sm bg-background/50 focus:outline-none focus:ring-1 focus:ring-primary" />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Interest Rate (% per annum)</label>
                  <input type="number" value={interestRate} onChange={e => setInterestRate(e.target.value)} className="w-full border border-white/10 rounded-md px-3 py-2 text-sm bg-background/50 focus:outline-none focus:ring-1 focus:ring-primary" />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Tenure (Years)</label>
                  <input type="number" value={tenure} onChange={e => setTenure(e.target.value)} className="w-full border border-white/10 rounded-md px-3 py-2 text-sm bg-background/50 focus:outline-none focus:ring-1 focus:ring-primary" />
                </div>
              </div>
            ) : (
              <div className="grid gap-4">
                {activeTool !== "area" && (
                  <div>
                    <label className="block text-sm font-medium mb-1">Crop Type</label>
                    <select value={crop} onChange={e => setCrop(e.target.value)} className="w-full border border-white/10 rounded-md px-3 py-2 text-sm bg-background/50 focus:outline-none focus:ring-1 focus:ring-primary">
                      <option>Wheat</option>
                      <option>Cotton</option>
                      <option>Rice</option>
                    </select>
                  </div>
                )}
                <div>
                  <label className="block text-sm font-medium mb-1">Area (Acres)</label>
                  <input type="number" value={area} onChange={e => setArea(e.target.value)} className="w-full border border-white/10 rounded-md px-3 py-2 text-sm bg-background/50 focus:outline-none focus:ring-1 focus:ring-primary" />
                </div>
              </div>
            )}
            
            <Button onClick={calculateResult} className="w-full mt-4">Generate Calculation</Button>

            {result && (
              <div className="mt-8 p-6 bg-primary/10 border border-primary/20 rounded-xl animate-in fade-in slide-in-from-bottom-4">
                <h3 className="text-sm font-medium text-primary mb-1">{result.title}</h3>
                <div className="text-3xl font-bold mb-2">{result.value}</div>
                <p className="text-sm text-muted-foreground">{result.note}</p>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
