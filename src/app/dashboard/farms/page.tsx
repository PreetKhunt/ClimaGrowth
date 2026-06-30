"use client";

import { useState, useEffect } from "react";
import { Map as MapIcon, MapPin, Activity, Droplets, Leaf, Plus, Settings2, Eye, Loader2 } from "lucide-react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger, DialogFooter } from "@/components/ui/dialog";
import { DynamicMap } from "@/components/DynamicMap";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { farmSchema, FarmInput } from "@/lib/validations/farm";
import { createFarm, fetchFarms, deleteFarm } from "@/actions/farm-actions";

export default function FarmManagementPage() {
  const [farms, setFarms] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [selectedFarm, setSelectedFarm] = useState<any | null>(null);

  const form = useForm<FarmInput>({
    resolver: zodResolver(farmSchema) as any,
    defaultValues: {
      name: "",
      area_acres: 0,
      soil_type: "",
      crop_type: "",
      irrigation_type: "",
      water_source: "",
      coordinates: { lat: 22.3039, lng: 70.8022 }, // Default to Rajkot
    }
  });

  const loadFarms = async () => {
    setLoading(true);
    const res = await fetchFarms();
    if (res.success && res.data) {
      setFarms(res.data);
    }
    setLoading(false);
  };

  useEffect(() => {
    loadFarms();
  }, []);

  const onSubmit = async (data: FarmInput) => {
    setIsSubmitting(true);
    try {
      const res = await createFarm(data);
      if (!res.success) throw new Error(res.error);
      setIsDialogOpen(false);
      form.reset();
      await loadFarms();
    } catch (err: any) {
      alert(err.message || 'Failed to add farm');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm('Are you sure you want to delete this farm?')) return;
    try {
      const res = await deleteFarm(id);
      if (!res.success) throw new Error(res.error);
      await loadFarms();
    } catch (err: any) {
      alert(err.message || 'Failed to delete farm');
    }
  };

  return (
    <div className="p-8 max-w-7xl mx-auto space-y-8">
      <div className="flex justify-between items-end">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Farm Management</h1>
          <p className="text-muted-foreground mt-1">Monitor all your farm plots via satellite GIS and IoT sensors.</p>
        </div>
        
        <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
          <DialogTrigger render={<Button className="bg-primary text-primary-foreground gap-2" />}>
            <Plus size={16} /> Add New Farm
          </DialogTrigger>
          <DialogContent className="sm:max-w-[700px] bg-card border-white/10">
            <DialogHeader>
              <DialogTitle>Add New Farm Plot</DialogTitle>
            </DialogHeader>
            <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4 mt-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <label className="text-sm font-medium">Farm Name</label>
                  <input {...form.register('name')} className="w-full bg-black/40 border border-white/10 rounded-md p-2 text-sm" placeholder="e.g. North Plot" />
                  {form.formState.errors.name && <p className="text-red-400 text-xs">{form.formState.errors.name.message}</p>}
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-medium">Area (Acres)</label>
                  <input type="number" step="0.1" {...form.register('area_acres')} className="w-full bg-black/40 border border-white/10 rounded-md p-2 text-sm" placeholder="e.g. 5.5" />
                  {form.formState.errors.area_acres && <p className="text-red-400 text-xs">{form.formState.errors.area_acres.message}</p>}
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-medium">Soil Type</label>
                  <input {...form.register('soil_type')} className="w-full bg-black/40 border border-white/10 rounded-md p-2 text-sm" placeholder="e.g. Black Cotton" />
                  {form.formState.errors.soil_type && <p className="text-red-400 text-xs">{form.formState.errors.soil_type.message}</p>}
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-medium">Crop Type</label>
                  <input {...form.register('crop_type')} className="w-full bg-black/40 border border-white/10 rounded-md p-2 text-sm" placeholder="e.g. Bt Cotton" />
                  {form.formState.errors.crop_type && <p className="text-red-400 text-xs">{form.formState.errors.crop_type.message}</p>}
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-medium">Irrigation Type</label>
                  <input {...form.register('irrigation_type')} className="w-full bg-black/40 border border-white/10 rounded-md p-2 text-sm" placeholder="e.g. Drip" />
                  {form.formState.errors.irrigation_type && <p className="text-red-400 text-xs">{form.formState.errors.irrigation_type.message}</p>}
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-medium">Water Source</label>
                  <input {...form.register('water_source')} className="w-full bg-black/40 border border-white/10 rounded-md p-2 text-sm" placeholder="e.g. Borewell" />
                  {form.formState.errors.water_source && <p className="text-red-400 text-xs">{form.formState.errors.water_source.message}</p>}
                </div>
              </div>
              
              <div className="space-y-2">
                <label className="text-sm font-medium">Select Location on Map</label>
                <div className="h-[250px] w-full rounded-md overflow-hidden border border-white/10">
                  <DynamicMap 
                    center={[22.3039, 70.8022]} 
                    zoom={10} 
                    marker={form.watch('coordinates') ? [form.watch('coordinates').lat, form.watch('coordinates').lng] : undefined}
                    onLocationSelect={(lat, lng) => form.setValue('coordinates', { lat, lng })}
                  />
                </div>
              </div>

              <DialogFooter>
                <Button type="button" variant="outline" onClick={() => setIsDialogOpen(false)}>Cancel</Button>
                <Button type="submit" disabled={isSubmitting} className="bg-primary text-black">
                  {isSubmitting ? <Loader2 className="animate-spin mr-2 h-4 w-4" /> : null}
                  Save Farm
                </Button>
              </DialogFooter>
            </form>
          </DialogContent>
        </Dialog>

        {/* Farm Details Dialog */}
        <Dialog open={!!selectedFarm} onOpenChange={(open) => !open && setSelectedFarm(null)}>
          <DialogContent className="sm:max-w-[800px] bg-card border-white/10 p-0 overflow-hidden">
            {selectedFarm && (
              <div className="flex flex-col">
                <div className="relative h-[250px] w-full">
                  <img 
                    src={selectedFarm.images?.[0] || "https://images.unsplash.com/photo-1586771107445-d3af1b6d1973?q=80&w=1000&auto=format&fit=crop"} 
                    alt={selectedFarm.name}
                    className="w-full h-full object-cover"
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/40 to-transparent" />
                  <div className="absolute bottom-4 left-6 right-6 flex justify-between items-end">
                    <div>
                      <h2 className="text-3xl font-bold text-white mb-1">{selectedFarm.name}</h2>
                      <div className="flex items-center gap-3 text-sm text-white/80">
                        <span className="flex items-center gap-1"><MapPin size={14} /> {selectedFarm.area_acres} Acres</span>
                        <span className="flex items-center gap-1"><MapIcon size={14} /> {selectedFarm.coordinates?.lat?.toFixed(4)}, {selectedFarm.coordinates?.lng?.toFixed(4)}</span>
                      </div>
                    </div>
                    <div className="bg-primary/20 backdrop-blur-md border border-primary/30 px-3 py-1.5 rounded-full text-primary font-medium text-sm flex items-center gap-2">
                      <Activity size={14} /> Active Monitoring
                    </div>
                  </div>
                </div>
                
                <div className="p-6 grid grid-cols-2 gap-6">
                  <div className="space-y-6">
                    <div>
                      <h3 className="text-sm font-medium text-muted-foreground mb-3 uppercase tracking-wider">Agronomy Profile</h3>
                      <div className="grid grid-cols-2 gap-3">
                        <div className="bg-black/20 p-3 rounded-lg border border-white/5">
                          <div className="text-xs text-muted-foreground mb-1 flex items-center gap-1"><Leaf size={12}/> Crop Type</div>
                          <div className="font-semibold text-sm">{selectedFarm.crop_type}</div>
                        </div>
                        <div className="bg-black/20 p-3 rounded-lg border border-white/5">
                          <div className="text-xs text-muted-foreground mb-1 flex items-center gap-1"><Activity size={12}/> Soil Type</div>
                          <div className="font-semibold text-sm">{selectedFarm.soil_type}</div>
                        </div>
                        <div className="bg-black/20 p-3 rounded-lg border border-white/5 col-span-2">
                          <div className="text-xs text-muted-foreground mb-1 flex items-center gap-1"><Droplets size={12}/> Irrigation & Water Source</div>
                          <div className="font-semibold text-sm">{selectedFarm.irrigation_type} • {selectedFarm.water_source}</div>
                        </div>
                      </div>
                    </div>
                    
                    <div>
                      <h3 className="text-sm font-medium text-muted-foreground mb-3 uppercase tracking-wider">System Records</h3>
                      <div className="space-y-2 text-sm">
                        <div className="flex justify-between border-b border-white/5 pb-2">
                          <span className="text-muted-foreground">Created</span>
                          <span>{new Date(selectedFarm.created_at).toLocaleDateString()}</span>
                        </div>
                        <div className="flex justify-between border-b border-white/5 pb-2">
                          <span className="text-muted-foreground">Farm ID</span>
                          <span className="font-mono text-xs">{selectedFarm.id.split('-')[0]}...</span>
                        </div>
                      </div>
                    </div>
                  </div>
                  
                  <div className="space-y-6">
                    <div>
                      <h3 className="text-sm font-medium text-muted-foreground mb-3 uppercase tracking-wider">Current Conditions</h3>
                      <div className="bg-black/20 p-4 rounded-lg border border-white/5 space-y-4">
                        <div className="flex justify-between items-center">
                          <span className="text-sm text-muted-foreground">Soil Moisture</span>
                          <span className="font-semibold text-green-400">42% (Optimal)</span>
                        </div>
                        <div className="w-full bg-black/40 rounded-full h-2">
                          <div className="bg-green-400 h-2 rounded-full w-[42%]"></div>
                        </div>
                        <div className="flex justify-between items-center pt-2">
                          <span className="text-sm text-muted-foreground">Est. Yield Potential</span>
                          <span className="font-semibold text-primary">High</span>
                        </div>
                      </div>
                    </div>
                    
                    <div>
                      <h3 className="text-sm font-medium text-muted-foreground mb-3 uppercase tracking-wider">AI Recommendations</h3>
                      <div className="bg-primary/5 p-4 rounded-lg border border-primary/10 text-sm">
                        <p className="text-muted-foreground mb-2">Based on current satellite NDVI and soil data:</p>
                        <ul className="list-disc pl-4 space-y-1 text-white/90">
                          <li>Maintain current irrigation schedule.</li>
                          <li>Optimal harvest window approaching in 14 days.</li>
                          <li>No immediate disease threats detected in sector.</li>
                        </ul>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            )}
          </DialogContent>
        </Dialog>
      </div>

      {/* Main Map Area showing all farms */}
      <Card className="h-[400px] bg-card/40 border-white/5 relative overflow-hidden flex flex-col">
        <DynamicMap 
          center={[22.3039, 70.8022]} 
          zoom={9}
          readOnly={true}
          // We could map all farm markers here if we update DynamicMap to take an array of markers,
          // for now, we just show the map base.
        />
        <div className="absolute top-4 right-4 z-10 flex gap-2">
          <Button variant="secondary" size="sm" className="bg-black/80 backdrop-blur-md border-white/10 text-white gap-2">
            <MapIcon size={14} /> Satellite
          </Button>
          <Button variant="secondary" size="sm" className="bg-black/80 backdrop-blur-md border-white/10 text-white gap-2">
            <Activity size={14} /> NDVI Health
          </Button>
        </div>
      </Card>

      {/* Farm List */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {loading ? (
          <div className="col-span-3 flex justify-center py-12"><Loader2 className="animate-spin text-primary" /></div>
        ) : farms.length === 0 ? (
          <Card className="col-span-3 p-12 bg-card/40 border-white/5 flex flex-col items-center justify-center text-center">
            <Leaf size={48} className="text-muted-foreground mb-4" />
            <h3 className="text-xl font-bold mb-2">No Farms Found</h3>
            <p className="text-muted-foreground mb-6 max-w-md">You haven't added any farms yet. Connect your first farm plot to start monitoring health and irrigation.</p>
            <Button onClick={() => setIsDialogOpen(true)} className="bg-primary text-primary-foreground gap-2"><Plus size={16} /> Add Your First Farm</Button>
          </Card>
        ) : farms.map(farm => (
          <Card key={farm.id} className="p-6 bg-card/40 border-white/5 group hover:bg-card/60 transition-all">
            <div className="flex justify-between items-start mb-4">
              <div>
                <h3 className="text-xl font-bold mb-1">{farm.name}</h3>
                <div className="flex items-center gap-2 text-sm text-muted-foreground">
                  <MapPin size={14} /> {farm.area_acres} Acres • {farm.coordinates?.lat?.toFixed(2)}, {farm.coordinates?.lng?.toFixed(2)}
                </div>
              </div>
              <Button variant="ghost" size="icon" className="text-red-400 hover:text-red-300 hover:bg-red-400/10" onClick={() => handleDelete(farm.id)} title="Delete Farm">
                <Settings2 size={18} />
              </Button>
            </div>
            
            <div className="grid grid-cols-2 gap-4 mb-6">
              <div className="bg-black/20 p-3 rounded-lg border border-white/5">
                <div className="text-xs text-muted-foreground mb-1 flex items-center gap-1"><Leaf size={12}/> Crop</div>
                <div className="font-semibold text-sm">{farm.crop_type}</div>
              </div>
              <div className="bg-black/20 p-3 rounded-lg border border-white/5">
                <div className="text-xs text-muted-foreground mb-1 flex items-center gap-1"><Activity size={12}/> Soil</div>
                <div className="font-semibold text-sm">{farm.soil_type}</div>
              </div>
              <div className="bg-black/20 p-3 rounded-lg border border-white/5 col-span-2">
                <div className="text-xs text-muted-foreground mb-1 flex items-center gap-1"><Droplets size={12}/> Irrigation</div>
                <div className="font-semibold text-sm">{farm.irrigation_type} ({farm.water_source})</div>
              </div>
            </div>
            
            <div className="flex gap-2">
              <Button className="w-full bg-primary/10 text-primary hover:bg-primary/20 border border-primary/20 gap-2" onClick={() => setSelectedFarm(farm)}>
                <Eye size={16} /> View Details
              </Button>
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}
