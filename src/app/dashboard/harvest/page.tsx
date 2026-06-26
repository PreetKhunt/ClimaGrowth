"use client";

import { Warehouse, Truck, CheckCircle2, Box, ArrowRight, Package, Loader2 } from "lucide-react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

const harvestProgress = [
  { stage: "Maturity Check", status: "completed", date: "10 Oct 2026" },
  { stage: "Harvesting", status: "completed", date: "12 Oct 2026" },
  { stage: "Drying & Cleaning", status: "in-progress", date: "Currently Active" },
  { stage: "Packaging", status: "pending", date: "Expected 15 Oct" },
  { stage: "Market Transport", status: "pending", date: "Expected 16 Oct" },
];

const inventory = [
  { item: "Premium Wheat (HD-2967)", quantity: "18 Quintals", capacity: "80%", type: "produce" },
  { item: "Empty Jute Bags", quantity: "250 Units", capacity: "40%", type: "supplies" },
  { item: "DAP Fertilizer (Leftover)", quantity: "2 Bags", capacity: "10%", type: "supplies" },
];

export default function HarvestStoragePage() {
  return (
    <div className="p-8 max-w-7xl mx-auto space-y-8">
      <div className="flex justify-between items-end">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Harvest & Storage</h1>
          <p className="text-muted-foreground mt-1">Track post-harvest operations, warehousing, and inventory.</p>
        </div>
        <Button className="gap-2 bg-primary text-primary-foreground"><Package size={16} /> New Inventory Entry</Button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        
        {/* Harvest Pipeline */}
        <Card className="lg:col-span-2 p-6 bg-card/40 border-white/5">
          <h3 className="text-lg font-bold mb-6 flex items-center gap-2"><ArrowRight className="text-primary"/> Active Harvest Pipeline (Wheat)</h3>
          
          <div className="flex flex-col md:flex-row justify-between items-start md:items-center relative">
            {/* Connecting Line */}
            <div className="hidden md:block absolute top-6 left-10 right-10 h-0.5 bg-white/5 z-0" />
            
            {harvestProgress.map((step, i) => (
              <div key={i} className="relative z-10 flex flex-row md:flex-col items-center gap-4 md:gap-2 mb-6 md:mb-0 w-full md:w-32">
                <div className={`w-12 h-12 rounded-full flex items-center justify-center shrink-0 border-4 border-card
                  ${step.status === 'completed' ? 'bg-primary text-primary-foreground shadow-[0_0_15px_rgba(0,255,136,0.4)]' : 
                    step.status === 'in-progress' ? 'bg-blue-500 text-white shadow-[0_0_15px_rgba(59,130,246,0.4)]' : 'bg-black/40 text-muted-foreground border-white/10'}`}
                >
                  {step.status === 'completed' ? <CheckCircle2 size={20} /> : step.status === 'in-progress' ? <Loader2 className="animate-spin" size={20} /> : <span className="font-bold">{i + 1}</span>}
                </div>
                <div className="text-left md:text-center">
                  <div className={`font-semibold text-sm ${step.status === 'pending' ? 'text-muted-foreground' : 'text-white'}`}>{step.stage}</div>
                  <div className="text-xs text-muted-foreground">{step.date}</div>
                </div>
              </div>
            ))}
          </div>
          
          <div className="mt-10 p-4 bg-blue-500/10 border border-blue-500/20 rounded-xl flex items-start gap-4">
            <Loader2 className="animate-spin text-blue-400 shrink-0 mt-0.5" size={18} />
            <div>
              <h4 className="font-semibold text-sm text-blue-100">Drying in Progress</h4>
              <p className="text-sm text-blue-200/70 mt-1">Moisture content is currently at 18%. Target is 12%. Expected to complete in 48 hours under current weather conditions.</p>
            </div>
          </div>
        </Card>

        {/* Warehouse Status */}
        <Card className="p-6 bg-card/40 border-white/5">
          <h3 className="text-lg font-bold mb-6 flex items-center gap-2"><Warehouse className="text-amber-400"/> Primary Warehouse</h3>
          
          <div className="mb-6 relative">
            <div className="flex justify-between text-sm mb-2">
              <span className="text-white font-medium">Storage Capacity</span>
              <span className="text-amber-400 font-bold">75%</span>
            </div>
            <div className="w-full h-3 rounded-full bg-black/40 overflow-hidden">
              <div className="h-full rounded-full transition-all duration-1000 bg-amber-400 shadow-[0_0_10px_rgba(251,191,36,0.8)]" style={{ width: `75%` }} />
            </div>
            <p className="text-xs text-muted-foreground mt-2">1,500 sq ft available out of 6,000 sq ft.</p>
          </div>

          <h4 className="font-semibold text-sm mb-4 text-white/80 uppercase tracking-wider">Current Inventory</h4>
          <div className="space-y-3">
            {inventory.map((item, i) => (
              <div key={i} className="flex justify-between items-center bg-black/20 p-3 rounded-lg border border-white/5">
                <div className="flex items-center gap-3">
                  <div className={`w-8 h-8 rounded-md flex items-center justify-center ${item.type === 'produce' ? 'bg-primary/20 text-primary' : 'bg-white/10 text-muted-foreground'}`}>
                    <Box size={14} />
                  </div>
                  <div>
                    <div className="font-semibold text-sm">{item.item}</div>
                    <div className="text-xs text-muted-foreground">{item.quantity}</div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </Card>
      </div>
      
      {/* Logistics */}
      <Card className="p-6 bg-card/40 border-white/5 flex items-center justify-between">
        <div className="flex items-center gap-4">
          <div className="w-12 h-12 rounded-full bg-white/5 flex items-center justify-center">
            <Truck size={24} className="text-muted-foreground" />
          </div>
          <div>
            <h3 className="font-bold text-lg">Transport Logistics</h3>
            <p className="text-sm text-muted-foreground">Schedule a truck for market transport. Current rates: ₹150/km.</p>
          </div>
        </div>
        <Button variant="outline">Book Transport</Button>
      </Card>

    </div>
  );
}
