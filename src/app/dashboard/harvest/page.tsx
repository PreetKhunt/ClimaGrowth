"use client";

import { useState, useEffect } from "react";
import { Warehouse, Truck, CheckCircle2, Box, ArrowRight, Package, Loader2, Calendar } from "lucide-react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger, DialogFooter } from "@/components/ui/dialog";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { fetchFarms } from "@/actions/farm-actions";
import { createTransportBooking, fetchTransportBookings } from "@/actions/harvest-actions";
import { transportBookingSchema } from "@/lib/validations/harvest";
import { inventorySchema, InventoryInput } from "@/lib/validations/inventory";
import { createInventory, fetchInventory, deleteInventory } from "@/actions/inventory-actions";

const harvestProgress = [
  { stage: "Maturity Check", status: "completed", date: "10 Oct 2026" },
  { stage: "Harvesting", status: "completed", date: "12 Oct 2026" },
  { stage: "Drying & Cleaning", status: "in-progress", date: "Currently Active" },
  { stage: "Packaging", status: "pending", date: "Expected 15 Oct" },
  { stage: "Market Transport", status: "pending", date: "Expected 16 Oct" },
];

const inventoryStatic = [
  { item: "Premium Wheat (HD-2967)", quantity: "18 Quintals", capacity: "80%", type: "produce" },
];

export default function HarvestStoragePage() {
  const [farms, setFarms] = useState<any[]>([]);
  const [bookings, setBookings] = useState<any[]>([]);
  const [inventoryItems, setInventoryItems] = useState<any[]>([]);
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [isInventoryDialogOpen, setIsInventoryDialogOpen] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isInventorySubmitting, setIsInventorySubmitting] = useState(false);
  const [loading, setLoading] = useState(true);

  const inventoryForm = useForm<InventoryInput>({
    resolver: zodResolver(inventorySchema) as any,
    defaultValues: {
      name: "",
      category: "produce",
      quantity: 0,
      unit: "Quintals",
      warehouse: "",
    }
  });

  const form = useForm<z.infer<typeof transportBookingSchema>>({
    resolver: zodResolver(transportBookingSchema) as any,
    defaultValues: {
      pickup_farm_id: "",
      vehicle_type: "Mini Truck",
      capacity_tons: 2,
      destination: "",
      pickup_date: "",
      pickup_time: "",
      contact_number: "",
      notes: ""
    }
  });

  const loadData = async () => {
    setLoading(true);
    const farmsRes = await fetchFarms();
    if (farmsRes.success && farmsRes.data) {
      setFarms(farmsRes.data);
      if (farmsRes.data.length > 0) {
        form.setValue("pickup_farm_id", farmsRes.data[0].id);
      }
    }
    
    const bookingsRes = await fetchTransportBookings();
    if (bookingsRes.success && bookingsRes.data) {
      setBookings(bookingsRes.data);
    }

    const inventoryRes = await fetchInventory();
    if (inventoryRes.success && inventoryRes.data) {
      setInventoryItems(inventoryRes.data);
    }
    
    setLoading(false);
  };

  useEffect(() => {
    loadData();
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const onSubmit = async (data: z.infer<typeof transportBookingSchema>) => {
    setIsSubmitting(true);
    try {
      const res = await createTransportBooking(data);
      if (!res.success) throw new Error(res.error);
      setIsDialogOpen(false);
      form.reset();
      await loadData();
    } catch (err: any) {
      alert(err.message || 'Failed to book transport');
    } finally {
      setIsSubmitting(false);
    }
  };

  const onInventorySubmit = async (data: InventoryInput) => {
    setIsInventorySubmitting(true);
    try {
      const res = await createInventory(data);
      if (!res.success) throw new Error(res.error);
      setIsInventoryDialogOpen(false);
      inventoryForm.reset();
      await loadData();
    } catch (err: any) {
      alert(err.message || 'Failed to add inventory');
    } finally {
      setIsInventorySubmitting(false);
    }
  };

  const handleDeleteInventory = async (id: string) => {
    if (!confirm('Are you sure you want to delete this item?')) return;
    try {
      const res = await deleteInventory(id);
      if (!res.success) throw new Error(res.error);
      await loadData();
    } catch (err: any) {
      alert(err.message || 'Failed to delete inventory');
    }
  };

  if (loading) {
    return <div className="p-8 flex justify-center"><Loader2 className="animate-spin text-primary w-8 h-8" /></div>;
  }

  return (
    <div className="p-8 max-w-7xl mx-auto space-y-8">
      <div className="flex justify-between items-end">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Harvest & Storage</h1>
          <p className="text-muted-foreground mt-1">Track post-harvest operations, warehousing, and inventory.</p>
        </div>
        
        <Dialog open={isInventoryDialogOpen} onOpenChange={setIsInventoryDialogOpen}>
          <DialogTrigger render={<Button className="gap-2 bg-primary text-primary-foreground"><Package size={16} /> New Inventory Entry</Button>} />
          <DialogContent className="sm:max-w-[500px] bg-card border-white/10">
            <DialogHeader>
              <DialogTitle>Add Inventory Item</DialogTitle>
            </DialogHeader>
            <form onSubmit={inventoryForm.handleSubmit(onInventorySubmit)} className="space-y-4 mt-4">
              <div className="space-y-2">
                <label className="text-sm font-medium">Item Name</label>
                <input {...inventoryForm.register('name')} className="w-full bg-black/40 border border-white/10 rounded-md p-2 text-sm" placeholder="e.g. Premium Wheat" />
                {inventoryForm.formState.errors.name && <p className="text-red-400 text-xs">{inventoryForm.formState.errors.name.message}</p>}
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <label className="text-sm font-medium">Category</label>
                  <select {...inventoryForm.register('category')} className="w-full bg-black/40 border border-white/10 rounded-md p-2 text-sm text-white">
                    <option value="produce">Produce (Harvest)</option>
                    <option value="supplies">Supplies</option>
                    <option value="equipment">Equipment</option>
                  </select>
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-medium">Warehouse</label>
                  <input {...inventoryForm.register('warehouse')} className="w-full bg-black/40 border border-white/10 rounded-md p-2 text-sm" placeholder="e.g. Primary Storage" />
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-medium">Quantity</label>
                  <input type="number" step="0.1" {...inventoryForm.register('quantity')} className="w-full bg-black/40 border border-white/10 rounded-md p-2 text-sm" />
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-medium">Unit</label>
                  <input {...inventoryForm.register('unit')} className="w-full bg-black/40 border border-white/10 rounded-md p-2 text-sm" placeholder="e.g. Quintals, Bags" />
                </div>
              </div>
              <DialogFooter>
                <Button type="button" variant="outline" onClick={() => setIsInventoryDialogOpen(false)}>Cancel</Button>
                <Button type="submit" disabled={isInventorySubmitting} className="bg-primary text-black">
                  {isInventorySubmitting ? <Loader2 className="animate-spin mr-2 h-4 w-4" /> : null} Save Item
                </Button>
              </DialogFooter>
            </form>
          </DialogContent>
        </Dialog>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Harvest Pipeline */}
        <Card className="lg:col-span-2 p-6 bg-card/40 border-white/5">
          <h3 className="text-lg font-bold mb-6 flex items-center gap-2"><ArrowRight className="text-primary"/> Active Harvest Pipeline (Wheat)</h3>
          
          <div className="flex flex-col md:flex-row justify-between items-start md:items-center relative">
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
            {inventoryItems.length === 0 && <div className="text-sm text-muted-foreground p-4 text-center">No inventory items.</div>}
            {inventoryItems.map((item) => (
              <div key={item.id} className="flex justify-between items-center bg-black/20 p-3 rounded-lg border border-white/5">
                <div className="flex items-center gap-3">
                  <div className={`w-8 h-8 rounded-md flex items-center justify-center ${item.category === 'produce' ? 'bg-primary/20 text-primary' : 'bg-white/10 text-muted-foreground'}`}>
                    <Box size={14} />
                  </div>
                  <div>
                    <div className="font-semibold text-sm">{item.name}</div>
                    <div className="text-xs text-muted-foreground">{item.quantity} {item.unit} • {item.warehouse || 'Unassigned'}</div>
                  </div>
                </div>
                <Button variant="ghost" size="sm" className="text-red-400 hover:text-red-300 hover:bg-red-400/10 h-8 px-2" onClick={() => handleDeleteInventory(item.id)}>
                  Delete
                </Button>
              </div>
            ))}
          </div>
        </Card>
      </div>
      
      {/* Logistics & Bookings */}
      <div className="space-y-4">
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
          
          <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
            <DialogTrigger render={<Button className="w-full h-12 text-lg mt-4 bg-primary text-primary-foreground" />}>
              <Truck size={18} className="mr-2" /> Book Transport Now
            </DialogTrigger>
            <DialogContent className="sm:max-w-[600px] bg-card border-white/10">
              <DialogHeader>
                <DialogTitle>Book Transport Vehicle</DialogTitle>
              </DialogHeader>
              
              {farms.length === 0 ? (
                <div className="p-4 text-center">You must add a farm before booking transport.</div>
              ) : (
                <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4 mt-4">
                  <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-2 col-span-2">
                      <label className="text-sm font-medium">Pickup Farm</label>
                      <select {...form.register('pickup_farm_id')} className="w-full bg-black/40 border border-white/10 rounded-md p-2 text-sm text-white">
                        {farms.map(f => <option key={f.id} value={f.id}>{f.name}</option>)}
                      </select>
                    </div>

                    <div className="space-y-2">
                      <label className="text-sm font-medium">Vehicle Type</label>
                      <select {...form.register('vehicle_type')} className="w-full bg-black/40 border border-white/10 rounded-md p-2 text-sm text-white">
                        <option value="Mini Truck">Mini Truck (2-4 Tons)</option>
                        <option value="Heavy Truck">Heavy Truck (10+ Tons)</option>
                        <option value="Tractor Trailor">Tractor Trailor</option>
                        <option value="Refrigerated Van">Refrigerated Van</option>
                      </select>
                    </div>
                    
                    <div className="space-y-2">
                      <label className="text-sm font-medium">Load Capacity (Tons)</label>
                      <input type="number" step="0.5" {...form.register('capacity_tons')} className="w-full bg-black/40 border border-white/10 rounded-md p-2 text-sm" />
                      {form.formState.errors.capacity_tons && <p className="text-red-400 text-xs">{form.formState.errors.capacity_tons.message}</p>}
                    </div>

                    <div className="space-y-2 col-span-2">
                      <label className="text-sm font-medium">Destination Market/Warehouse</label>
                      <input {...form.register('destination')} className="w-full bg-black/40 border border-white/10 rounded-md p-2 text-sm" placeholder="e.g. APMC Market, Rajkot" />
                      {form.formState.errors.destination && <p className="text-red-400 text-xs">{form.formState.errors.destination.message}</p>}
                    </div>

                    <div className="space-y-2">
                      <label className="text-sm font-medium">Pickup Date</label>
                      <input type="date" {...form.register('pickup_date')} className="w-full bg-black/40 border border-white/10 rounded-md p-2 text-sm [color-scheme:dark]" />
                      {form.formState.errors.pickup_date && <p className="text-red-400 text-xs">{form.formState.errors.pickup_date.message}</p>}
                    </div>
                    
                    <div className="space-y-2">
                      <label className="text-sm font-medium">Pickup Time</label>
                      <input type="time" {...form.register('pickup_time')} className="w-full bg-black/40 border border-white/10 rounded-md p-2 text-sm [color-scheme:dark]" />
                      {form.formState.errors.pickup_time && <p className="text-red-400 text-xs">{form.formState.errors.pickup_time.message}</p>}
                    </div>
                    
                    <div className="space-y-2 col-span-2">
                      <label className="text-sm font-medium">Contact Number</label>
                      <input {...form.register('contact_number')} className="w-full bg-black/40 border border-white/10 rounded-md p-2 text-sm" placeholder="+91..." />
                      {form.formState.errors.contact_number && <p className="text-red-400 text-xs">{form.formState.errors.contact_number.message}</p>}
                    </div>
                  </div>

                  <DialogFooter>
                    <Button type="button" variant="outline" onClick={() => setIsDialogOpen(false)}>Cancel</Button>
                    <Button type="submit" disabled={isSubmitting} className="bg-primary text-black">
                      {isSubmitting ? <Loader2 className="animate-spin mr-2 h-4 w-4" /> : null}
                      Confirm Booking
                    </Button>
                  </DialogFooter>
                </form>
              )}
            </DialogContent>
          </Dialog>
        </Card>

        {/* Existing Bookings List */}
        {bookings.length > 0 && (
          <Card className="p-6 bg-card/40 border-white/5">
            <h3 className="text-lg font-bold mb-4">Active Bookings</h3>
            <div className="space-y-4">
              {bookings.map((booking) => (
                <div key={booking.id} className="flex justify-between items-center bg-black/20 p-4 rounded-lg border border-white/5">
                  <div>
                    <div className="font-semibold flex items-center gap-2">
                      {booking.vehicle_type} <span className="text-muted-foreground text-xs font-normal">to</span> {booking.destination}
                    </div>
                    <div className="text-sm text-muted-foreground mt-1 flex items-center gap-2">
                      <Calendar size={12} /> {booking.pickup_date} at {booking.pickup_time}
                    </div>
                  </div>
                  <div className="text-right">
                    <div className={`px-2 py-1 text-xs font-semibold uppercase tracking-wider rounded-md border
                      ${booking.status === 'pending' ? 'border-amber-500/20 text-amber-500 bg-amber-500/10' : 
                        booking.status === 'confirmed' ? 'border-blue-500/20 text-blue-500 bg-blue-500/10' : 
                        'border-primary/20 text-primary bg-primary/10'}`}
                    >
                      {booking.status}
                    </div>
                    <div className="text-xs text-muted-foreground mt-1">{booking.capacity_tons} Tons</div>
                  </div>
                </div>
              ))}
            </div>
          </Card>
        )}
      </div>

    </div>
  );
}
