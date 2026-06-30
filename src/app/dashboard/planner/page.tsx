/* eslint-disable @typescript-eslint/no-explicit-any */
 
 
/* eslint-disable @typescript-eslint/no-unused-vars */
 
"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Leaf, Droplets, Banknote, Calendar, Sun, CheckCircle2, ChevronRight, Activity } from "lucide-react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

const steps = [
  { id: "farm", title: "Farm Details" },
  { id: "soil", title: "Soil & Water" },
  { id: "budget", title: "Budget & Season" },
];

export default function SmartCropPlannerPage() {
  const [currentStep, setCurrentStep] = useState(0);
  const [isGenerating, setIsGenerating] = useState(false);
  const [result, setResult] = useState<any>(null);

  const [formData, setFormData] = useState({
    size: "",
    district: "",
    soilType: "Black Soil",
    water: "Borewell",
    budget: "",
    season: "Kharif",
  });

  const generatePlan = () => {
    setIsGenerating(true);
    setTimeout(() => {
      setResult({
        crop: "Bt Cotton",
        investment: "₹35,000",
        expectedYield: "12 Quintals",
        estimatedProfit: "₹45,000",
        timeline: [
          { week: "Week 1", title: "Field Preparation", desc: "Deep ploughing and basal fertilizer application (DAP)." },
          { week: "Week 3", title: "Sowing", desc: "Dibbling seeds with 90x60 cm spacing." },
          { week: "Week 6", title: "First Irrigation", desc: "Apply 25% of remaining Urea." },
          { week: "Week 12", title: "Pest Management", desc: "Monitor for Pink Bollworm. Spray Neem oil." },
          { week: "Week 20", title: "First Picking", desc: "Harvest mature bolls." },
        ]
      });
      setIsGenerating(false);
    }, 2500);
  };

  return (
    <div className="p-8 max-w-5xl mx-auto">
      <div className="mb-8">
        <h1 className="text-3xl font-bold tracking-tight">Smart Crop Planner</h1>
        <p className="text-muted-foreground mt-1">AI-driven personalized crop scheduling and profit estimation.</p>
      </div>

      {!result ? (
        <Card className="bg-card/40 border-white/5 p-8 shadow-xl relative overflow-hidden">
          {/* Progress Indicator */}
          <div className="flex justify-between items-center mb-8 relative">
            <div className="absolute top-1/2 left-0 right-0 h-0.5 bg-white/5 -z-10" />
            <div className="absolute top-1/2 left-0 h-0.5 bg-primary transition-all duration-500 -z-10" style={{ width: `${(currentStep / (steps.length - 1)) * 100}%` }} />
            
            {steps.map((step, idx) => (
              <div key={step.id} className="flex flex-col items-center gap-2 bg-card px-2">
                <div className={`w-8 h-8 rounded-full flex items-center justify-center font-bold text-sm transition-colors ${idx <= currentStep ? 'bg-primary text-primary-foreground shadow-[0_0_15px_rgba(0,255,136,0.4)]' : 'bg-white/10 text-muted-foreground'}`}>
                  {idx < currentStep ? <CheckCircle2 size={16} /> : idx + 1}
                </div>
                <span className={`text-xs font-medium ${idx <= currentStep ? 'text-foreground' : 'text-muted-foreground'}`}>{step.title}</span>
              </div>
            ))}
          </div>

          {/* Form Area */}
          <div className="min-h-[250px] flex items-center">
            <AnimatePresence mode="wait">
              {currentStep === 0 && (
                <motion.div key="step1" initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -20 }} className="w-full space-y-4">
                  <div>
                    <label className="block text-sm font-medium mb-1">Farm Size (Acres)</label>
                    <input type="number" placeholder="e.g. 5" className="w-full border border-white/10 rounded-md px-4 py-3 bg-background/50 focus:ring-1 focus:ring-primary" value={formData.size} onChange={e => setFormData({...formData, size: e.target.value})} />
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-1">District / Location</label>
                    <input type="text" placeholder="e.g. Rajkot, Gujarat" className="w-full border border-white/10 rounded-md px-4 py-3 bg-background/50 focus:ring-1 focus:ring-primary" value={formData.district} onChange={e => setFormData({...formData, district: e.target.value})} />
                  </div>
                </motion.div>
              )}
              {currentStep === 1 && (
                <motion.div key="step2" initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -20 }} className="w-full space-y-4">
                  <div>
                    <label className="block text-sm font-medium mb-1">Primary Soil Type</label>
                    <select className="w-full border border-white/10 rounded-md px-4 py-3 bg-background/50 focus:ring-1 focus:ring-primary" value={formData.soilType} onChange={e => setFormData({...formData, soilType: e.target.value})}>
                      <option>Black Soil</option>
                      <option>Red Soil</option>
                      <option>Alluvial Soil</option>
                      <option>Sandy Soil</option>
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-1">Irrigation Source</label>
                    <select className="w-full border border-white/10 rounded-md px-4 py-3 bg-background/50 focus:ring-1 focus:ring-primary" value={formData.water} onChange={e => setFormData({...formData, water: e.target.value})}>
                      <option>Borewell</option>
                      <option>Canal</option>
                      <option>Rainfed (Monsoon only)</option>
                      <option>Drip Irrigation</option>
                    </select>
                  </div>
                </motion.div>
              )}
              {currentStep === 2 && (
                <motion.div key="step3" initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -20 }} className="w-full space-y-4">
                  <div>
                    <label className="block text-sm font-medium mb-1">Target Season</label>
                    <select className="w-full border border-white/10 rounded-md px-4 py-3 bg-background/50 focus:ring-1 focus:ring-primary" value={formData.season} onChange={e => setFormData({...formData, season: e.target.value})}>
                      <option>Kharif (Monsoon)</option>
                      <option>Rabi (Winter)</option>
                      <option>Zaid (Summer)</option>
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-1">Expected Budget (₹)</label>
                    <input type="number" placeholder="e.g. 50000" className="w-full border border-white/10 rounded-md px-4 py-3 bg-background/50 focus:ring-1 focus:ring-primary" value={formData.budget} onChange={e => setFormData({...formData, budget: e.target.value})} />
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </div>

          <div className="mt-8 flex justify-between">
            <Button variant="outline" onClick={() => setCurrentStep(c => Math.max(0, c - 1))} disabled={currentStep === 0 || isGenerating}>
              Back
            </Button>
            
            {currentStep < steps.length - 1 ? (
              <Button className="gap-2" onClick={() => setCurrentStep(c => c + 1)}>
                Next Step <ChevronRight size={16} />
              </Button>
            ) : (
              <Button className="bg-primary hover:bg-primary/90 text-primary-foreground gap-2" onClick={generatePlan} disabled={isGenerating}>
                {isGenerating ? (
                  <><Activity className="animate-spin" size={16} /> Analyzing Data...</>
                ) : (
                  <><Leaf size={16} /> Generate AI Plan</>
                )}
              </Button>
            )}
          </div>
        </Card>
      ) : (
        <motion.div initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} className="space-y-6">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <Card className="p-4 bg-primary/10 border-primary/20">
              <div className="text-sm font-medium text-primary mb-1">Recommended Crop</div>
              <div className="text-xl font-bold flex items-center gap-2"><Leaf size={18}/> {result.crop}</div>
            </Card>
            <Card className="p-4 bg-white/5 border-white/10">
              <div className="text-sm font-medium text-muted-foreground mb-1">Est. Investment</div>
              <div className="text-xl font-bold flex items-center gap-2"><Banknote size={18}/> {result.investment}</div>
            </Card>
            <Card className="p-4 bg-white/5 border-white/10">
              <div className="text-sm font-medium text-muted-foreground mb-1">Expected Yield</div>
              <div className="text-xl font-bold flex items-center gap-2"><Activity size={18}/> {result.expectedYield}</div>
            </Card>
            <Card className="p-4 bg-primary/10 border-primary/20">
              <div className="text-sm font-medium text-primary mb-1">Est. Net Profit</div>
              <div className="text-xl font-bold flex items-center gap-2 text-primary"><Sun size={18}/> {result.estimatedProfit}</div>
            </Card>
          </div>

          <Card className="bg-card/40 border-white/5 p-8">
            <h2 className="text-xl font-bold mb-6 flex items-center gap-2"><Calendar className="text-primary"/> Action Plan Timeline</h2>
            
            <div className="space-y-6 relative before:absolute before:inset-0 before:ml-5 before:-translate-x-px md:before:mx-auto md:before:translate-x-0 before:h-full before:w-0.5 before:bg-gradient-to-b before:from-transparent before:via-white/10 before:to-transparent">
              {result.timeline.map((event: any, i: number) => (
                <div key={i} className="relative flex items-center justify-between md:justify-normal md:odd:flex-row-reverse group is-active">
                  <div className="flex items-center justify-center w-10 h-10 rounded-full border border-white/10 bg-card shrink-0 md:order-1 md:group-odd:-translate-x-1/2 md:group-even:translate-x-1/2 shadow-[0_0_10px_rgba(0,255,136,0.2)] text-primary">
                    <CheckCircle2 size={18} />
                  </div>
                  <div className="w-[calc(100%-4rem)] md:w-[calc(50%-3rem)] p-4 rounded-xl bg-white/5 border border-white/10 hover:bg-white/10 transition-colors">
                    <div className="flex items-center justify-between mb-1">
                      <div className="font-bold text-primary">{event.title}</div>
                      <time className="font-mono text-xs text-muted-foreground">{event.week}</time>
                    </div>
                    <div className="text-sm text-muted-foreground">{event.desc}</div>
                  </div>
                </div>
              ))}
            </div>
          </Card>
          
          <Button variant="outline" className="w-full" onClick={() => setResult(null)}>Create New Plan</Button>
        </motion.div>
      )}
    </div>
  );
}
