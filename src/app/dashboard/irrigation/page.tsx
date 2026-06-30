"use client";

import { useState, useEffect } from "react";
import { Droplets, Power, CloudRain, Activity, AlertTriangle, Settings2, BarChart3, Loader2 } from "lucide-react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger, DialogFooter } from "@/components/ui/dialog";
import { fetchFarms } from "@/actions/farm-actions";
import { fetchIrrigationConfig, upsertIrrigationConfig, togglePumpStatus } from "@/actions/irrigation-actions";
import { irrigationConfigSchema } from "@/lib/validations/irrigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";

export default function SmartIrrigationPage() {
  const [farms, setFarms] = useState<any[]>([]);
  const [selectedFarmId, setSelectedFarmId] = useState<string | null>(null);
  const [config, setConfig] = useState<any>(null);
  const [pumpStatus, setPumpStatus] = useState(false);
  const [loading, setLoading] = useState(true);
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [ruleApplied, setRuleApplied] = useState(false);

  const form = useForm<z.infer<typeof irrigationConfigSchema>>({
    resolver: zodResolver(irrigationConfigSchema) as any,
    defaultValues: {
      farm_id: "",
      moisture_threshold: 40,
      temperature_threshold: 35,
      rain_detection_enabled: true,
      emergency_watering_enabled: false,
    }
  });

  const loadData = async () => {
    setLoading(true);
    const farmsRes = await fetchFarms();
    if (farmsRes.success && farmsRes.data && farmsRes.data.length > 0) {
      setFarms(farmsRes.data);
      const targetFarmId = selectedFarmId || farmsRes.data[0].id;
      setSelectedFarmId(targetFarmId);
      form.setValue("farm_id", targetFarmId);
      
      const configRes = await fetchIrrigationConfig(targetFarmId);
      if (configRes.success && configRes.data) {
        setConfig(configRes.data);
        setPumpStatus(configRes.data.pump_status === 'on');
        form.reset({
          farm_id: targetFarmId,
          moisture_threshold: configRes.data.moisture_threshold,
          temperature_threshold: configRes.data.temperature_threshold || 35,
          rain_detection_enabled: configRes.data.rain_detection_enabled,
          emergency_watering_enabled: configRes.data.emergency_watering_enabled,
        });
      } else {
        setConfig(null);
        setPumpStatus(false);
      }
    }
    setLoading(false);
  };

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    loadData();
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedFarmId]);

  const handleTogglePump = async () => {
    if (!selectedFarmId) return;
    const newStatus = !pumpStatus;
    setPumpStatus(newStatus); // Optimistic UI update
    
    try {
      const res = await togglePumpStatus(selectedFarmId, newStatus);
      if (!res.success) throw new Error(res.error);
    } catch (err: any) {
      alert(err.message || 'Failed to toggle pump.');
      setPumpStatus(!newStatus); // Revert
    }
  };

  const onSubmit = async (data: z.infer<typeof irrigationConfigSchema>) => {
    setIsSubmitting(true);
    try {
      const res = await upsertIrrigationConfig(data);
      if (!res.success) throw new Error(res.error);
      setIsDialogOpen(false);
      await loadData();
    } catch (err: any) {
      alert(err.message || 'Failed to save configuration');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (loading && farms.length === 0) {
    return <div className="p-8 flex justify-center"><Loader2 className="animate-spin text-primary w-8 h-8" /></div>;
  }

  if (farms.length === 0) {
    return (
      <div className="p-8 max-w-7xl mx-auto space-y-8 text-center">
        <h1 className="text-3xl font-bold tracking-tight">Smart Irrigation</h1>
        <p className="text-muted-foreground mt-4">You need to add a farm first before configuring smart irrigation.</p>
      </div>
    );
  }

  return (
    <div className="p-8 max-w-7xl mx-auto space-y-8">
      <div className="flex justify-between items-end">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Smart Irrigation</h1>
          <p className="text-muted-foreground mt-1">Control IoT pumps and monitor water usage across your farm.</p>
        </div>
        <div className="flex gap-4 items-center">
          <select 
            className="bg-black/40 border border-white/10 rounded-md p-2 text-sm text-white h-10"
            value={selectedFarmId || ""}
            onChange={(e) => setSelectedFarmId(e.target.value)}
          >
            {farms.map(f => <option key={f.id} value={f.id}>{f.name}</option>)}
          </select>

          <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
            <DialogTrigger render={<Button variant="outline" className="gap-2 h-10" />}>
              <Settings2 size={16} /> Config
            </DialogTrigger>
            <DialogContent className="sm:max-w-[500px] bg-card border-white/10">
              <DialogHeader>
                <DialogTitle>Automation Configuration</DialogTitle>
              </DialogHeader>
              <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4 mt-4">
                <div className="space-y-2">
                  <label className="text-sm font-medium">Moisture Threshold (%)</label>
                  <input type="number" {...form.register('moisture_threshold')} className="w-full bg-black/40 border border-white/10 rounded-md p-2 text-sm" />
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-medium">Temperature Threshold (°C)</label>
                  <input type="number" {...form.register('temperature_threshold')} className="w-full bg-black/40 border border-white/10 rounded-md p-2 text-sm" />
                </div>
                <div className="flex items-center gap-2">
                  <input type="checkbox" {...form.register('rain_detection_enabled')} id="rain" />
                  <label htmlFor="rain" className="text-sm font-medium">Enable Rain Detection Override</label>
                </div>
                <div className="flex items-center gap-2">
                  <input type="checkbox" {...form.register('emergency_watering_enabled')} id="emergency" />
                  <label htmlFor="emergency" className="text-sm font-medium">Enable Emergency Heat Watering</label>
                </div>

                <DialogFooter>
                  <Button type="button" variant="outline" onClick={() => setIsDialogOpen(false)}>Cancel</Button>
                  <Button type="submit" disabled={isSubmitting} className="bg-primary text-black">
                    {isSubmitting ? <Loader2 className="animate-spin mr-2 h-4 w-4" /> : null}
                    Save Config
                  </Button>
                </DialogFooter>
              </form>
            </DialogContent>
          </Dialog>

          <Button 
            className={`gap-2 h-10 ${pumpStatus ? 'bg-rose-500 hover:bg-rose-600 text-white' : 'bg-primary hover:bg-primary/90 text-primary-foreground'}`}
            onClick={handleTogglePump}
          >
            <Power size={16} /> {pumpStatus ? 'Stop Main Pump' : 'Start Main Pump'}
          </Button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {/* Main Status */}
        <Card className="col-span-1 md:col-span-2 p-6 bg-card/40 border-white/5 relative overflow-hidden">
          <div className="absolute top-0 right-0 p-6 opacity-10">
            <Droplets size={120} />
          </div>
          <div className="relative z-10 h-full flex flex-col justify-between">
            <div>
              <div className="flex items-center gap-3 mb-6">
                <div className={`w-3 h-3 rounded-full ${pumpStatus ? 'bg-primary animate-pulse shadow-[0_0_10px_rgba(0,255,136,0.8)]' : 'bg-rose-500'}`} />
                <span className="font-semibold text-sm tracking-wider uppercase">System {pumpStatus ? 'Active' : 'Offline'}</span>
              </div>
              <h2 className="text-4xl font-bold mb-2">4,250 Liters</h2>
              <p className="text-muted-foreground">Water consumed today</p>
            </div>
            
            <div className="grid grid-cols-3 gap-4 mt-8">
              <div className="bg-black/20 rounded-xl p-4 border border-white/5">
                <div className="text-xs text-muted-foreground mb-1">Flow Rate</div>
                <div className="font-bold text-lg">{pumpStatus ? '45 L/min' : '0 L/min'}</div>
              </div>
              <div className="bg-black/20 rounded-xl p-4 border border-white/5">
                <div className="text-xs text-muted-foreground mb-1">Moisture Threshold</div>
                <div className="font-bold text-lg text-amber-400">{config?.moisture_threshold || '40'}%</div>
              </div>
              <div className="bg-black/20 rounded-xl p-4 border border-white/5">
                <div className="text-xs text-muted-foreground mb-1">Next Rain</div>
                <div className="font-bold text-lg text-blue-400">{config?.rain_detection_enabled ? 'in 3 Days' : 'Ignored'}</div>
              </div>
            </div>
          </div>
        </Card>

        {/* Tank Level */}
        <Card className="p-6 bg-card/40 border-white/5 flex flex-col items-center justify-center relative">
          <h3 className="font-semibold mb-6 absolute top-6 left-6">Reservoir Level</h3>
          <div className="w-32 h-64 border-4 border-white/10 rounded-2xl relative overflow-hidden bg-black/20 mt-8">
            <div className="absolute bottom-0 left-0 right-0 h-[65%] bg-blue-500/80 transition-all duration-1000 ease-in-out relative">
              <div className="absolute top-0 inset-x-0 h-2 bg-blue-400/50" />
            </div>
          </div>
          <div className="mt-6 text-center">
            <div className="text-2xl font-bold">65% Full</div>
            <div className="text-sm text-muted-foreground">Approx. 12,000 L remaining</div>
          </div>
        </Card>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <Card className="p-6 bg-card/40 border-white/5">
          <h3 className="text-lg font-bold mb-4 flex items-center gap-2"><BarChart3 size={18} className="text-primary"/> Weekly Usage</h3>
          <div className="h-48 flex items-end gap-2 justify-between mt-8">
            {[45, 60, 30, 80, 55, 90, 40].map((h, i) => (
              <div key={i} className="w-full bg-blue-500/20 rounded-t-sm relative group hover:bg-blue-500/40 transition-colors" style={{ height: `${h}%` }}>
                <div className="absolute -top-8 left-1/2 -translate-x-1/2 text-xs opacity-0 group-hover:opacity-100 transition-opacity bg-black px-2 py-1 rounded border border-white/10">
                  {h}00L
                </div>
              </div>
            ))}
          </div>
          <div className="flex justify-between mt-2 text-xs text-muted-foreground">
            <span>Mon</span><span>Tue</span><span>Wed</span><span>Thu</span><span>Fri</span><span>Sat</span><span>Sun</span>
          </div>
        </Card>

        <Card className="p-6 bg-primary/5 border-primary/20">
          <h3 className="text-lg font-bold text-primary mb-4 flex items-center gap-2">
            <Activity size={18} /> AI Intelligence Engine
          </h3>
          <div className="space-y-4">
            {config?.rain_detection_enabled ? (
              <div className="bg-black/20 p-4 rounded-xl border border-white/5 flex gap-4 items-start">
                <CloudRain className="text-blue-400 shrink-0 mt-1" size={20} />
                <div>
                  <h4 className="font-semibold text-sm mb-1">Impending Rainfall Detected</h4>
                  <p className="text-sm text-muted-foreground">Weather models predict 15mm of rain in 72 hours. Consider delaying irrigation to save approximately 4,000 liters of water.</p>
                  <Button 
                    size="sm" 
                    variant="outline" 
                    className="mt-3"
                    onClick={async () => {
                      if (!selectedFarmId) return;
                      setPumpStatus(false);
                      try {
                        await togglePumpStatus(selectedFarmId, false);
                        setRuleApplied(true);
                      } catch (err: any) {
                        alert(err.message || 'Failed to apply rule');
                        setPumpStatus(true);
                      }
                    }}
                  >
                    {ruleApplied ? 'Rule Applied Successfully' : 'Apply Automation Rule'}
                  </Button>
                </div>
              </div>
            ) : (
              <div className="bg-black/20 p-4 rounded-xl border border-white/5 flex gap-4 items-start">
                <CloudRain className="text-muted-foreground shrink-0 mt-1" size={20} />
                <div>
                  <h4 className="font-semibold text-sm mb-1">Rain Detection Disabled</h4>
                  <p className="text-sm text-muted-foreground">Enable rain detection in config to automatically pause irrigation during rainfall.</p>
                </div>
              </div>
            )}
            
            <div className="bg-black/20 p-4 rounded-xl border border-white/5 flex gap-4 items-start">
              <AlertTriangle className="text-amber-400 shrink-0 mt-1" size={20} />
              <div>
                <h4 className="font-semibold text-sm mb-1">Pressure Drop in Line 4</h4>
                <p className="text-sm text-muted-foreground">IoT sensors detect a 12% pressure drop in the Drip Line. This typically indicates a minor leak or blocked emitter.</p>
              </div>
            </div>
          </div>
        </Card>
      </div>
    </div>
  );
}
