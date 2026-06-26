"use client";

import { useState, useEffect } from "react";
import { Map, MapPin, Activity, Droplets, Leaf, Plus, Settings2, Eye, Loader2 } from "lucide-react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { createClient } from "@/lib/supabase/client";

export default function FarmManagementPage() {
  const supabase = createClient();
  const [farms, setFarms] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadFarms() {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      const { data, error } = await supabase
        .from('farms')
        .select('*')
        .eq('user_id', user.id);
        
      if (!error && data) {
        setFarms(data);
      }
      setLoading(false);
    }
    loadFarms();
  }, [supabase]);
  return (
    <div className="p-8 max-w-7xl mx-auto space-y-8">
      <div className="flex justify-between items-end">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Farm Management</h1>
          <p className="text-muted-foreground mt-1">Monitor all your farm plots via satellite GIS and IoT sensors.</p>
        </div>
        <Button className="bg-primary text-primary-foreground gap-2"><Plus size={16} /> Add New Farm</Button>
      </div>

      {/* Mock Map Area */}
      <Card className="h-[400px] bg-card/40 border-white/5 relative overflow-hidden flex flex-col">
        <div className="absolute inset-0 z-0 opacity-40 bg-[url('https://images.unsplash.com/photo-1595804369792-74d306b3fa1d?q=80&w=2070&auto=format&fit=crop')] bg-cover bg-center mix-blend-overlay" />
        <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent z-0" />
        
        <div className="relative z-10 p-4 flex justify-end">
          <div className="flex gap-2">
            <Button 
              variant="secondary" 
              size="sm" 
              className="bg-black/50 backdrop-blur-md border-white/10 text-white gap-2"
              onClick={() => window.open('https://www.google.com/maps?t=k', '_blank')}
            >
              <Map size={14} /> Satellite
            </Button>
            <Button variant="secondary" size="sm" className="bg-black/50 backdrop-blur-md border-white/10 text-white gap-2">
              <Activity size={14} /> NDVI Health
            </Button>
          </div>
        </div>

        <div className="relative z-10 mt-auto p-6">
          <div className="flex items-center gap-3 mb-2">
            <div className="w-3 h-3 rounded-full bg-primary animate-pulse" />
            <span className="font-semibold text-white tracking-widest uppercase text-xs">Live Satellite Feed</span>
          </div>
          <h3 className="text-2xl font-bold text-white">Rajkot District Region</h3>
        </div>
        
        {/* Mock Pins */}
        <div className="absolute top-[40%] left-[30%] z-10">
          <div className="w-4 h-4 rounded-full bg-primary shadow-[0_0_15px_rgba(0,255,136,0.8)] animate-bounce" />
        </div>
        <div className="absolute top-[60%] left-[55%] z-10">
          <div className="w-4 h-4 rounded-full bg-amber-400 shadow-[0_0_15px_rgba(251,191,36,0.8)] animate-bounce" style={{ animationDelay: '0.2s' }} />
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
            <Button className="bg-primary text-primary-foreground gap-2"><Plus size={16} /> Add Your First Farm</Button>
          </Card>
        ) : farms.map(farm => (
          <Card key={farm.id} className="p-6 bg-card/40 border-white/5 group hover:bg-card/60 transition-all">
            <div className="flex justify-between items-start mb-4">
              <div>
                <h3 className="text-xl font-bold mb-1">{farm.name}</h3>
                <div className="flex items-center gap-2 text-sm text-muted-foreground">
                  <MapPin size={14} /> {farm.area} • {farm.lat}
                </div>
              </div>
              <Button variant="ghost" size="icon" className="text-muted-foreground hover:text-white">
                <Settings2 size={18} />
              </Button>
            </div>
            
            <div className="grid grid-cols-2 gap-4 mb-6">
              <div className="bg-black/20 p-3 rounded-lg border border-white/5">
                <div className="text-xs text-muted-foreground mb-1 flex items-center gap-1"><Leaf size={12}/> Crop</div>
                <div className="font-semibold text-sm">{farm.crop}</div>
              </div>
              <div className="bg-black/20 p-3 rounded-lg border border-white/5">
                <div className="text-xs text-muted-foreground mb-1 flex items-center gap-1"><Activity size={12}/> Health Score</div>
                <div className={`font-bold text-sm ${farm.health > 80 ? 'text-primary' : 'text-amber-400'}`}>{farm.health}/100</div>
              </div>
              <div className="bg-black/20 p-3 rounded-lg border border-white/5 col-span-2">
                <div className="text-xs text-muted-foreground mb-1 flex items-center gap-1"><Droplets size={12}/> Irrigation Status</div>
                <div className="font-semibold text-sm">{farm.water}</div>
              </div>
            </div>
            
            <div className="flex gap-2">
              <Button className="w-full bg-primary/10 text-primary hover:bg-primary/20 border border-primary/20 gap-2">
                <Eye size={16} /> View Details
              </Button>
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}
