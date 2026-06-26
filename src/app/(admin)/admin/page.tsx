import { Users, IndianRupee, AlertCircle, ShoppingBag } from "lucide-react";
import { Card } from "@/components/ui/card";

export default function AdminDashboard() {
  return (
    <div className="p-8 max-w-6xl mx-auto">
      <div className="mb-8">
        <h1 className="text-3xl font-bold tracking-tight">Admin CMS</h1>
        <p className="text-muted-foreground mt-1">Platform overview and management console</p>
      </div>

      <div className="grid gap-6 md:grid-cols-4 mb-8">
        <Card className="bg-card/40 border-white/5 p-6 shadow-sm">
          <div className="flex items-center gap-4 mb-2">
            <Users className="text-blue-400" size={24} />
            <div className="text-sm font-medium text-muted-foreground">Total Farmers</div>
          </div>
          <div className="text-3xl font-bold">1,248</div>
          <div className="text-xs text-green-400 mt-2">+12% this month</div>
        </Card>
        
        <Card className="bg-card/40 border-white/5 p-6 shadow-sm">
          <div className="flex items-center gap-4 mb-2">
            <IndianRupee className="text-primary" size={24} />
            <div className="text-sm font-medium text-muted-foreground">Market Revenue</div>
          </div>
          <div className="text-3xl font-bold">₹4.2L</div>
          <div className="text-xs text-green-400 mt-2">+5% this week</div>
        </Card>

        <Card className="bg-card/40 border-white/5 p-6 shadow-sm">
          <div className="flex items-center gap-4 mb-2">
            <ShoppingBag className="text-amber-400" size={24} />
            <div className="text-sm font-medium text-muted-foreground">Active Orders</div>
          </div>
          <div className="text-3xl font-bold">84</div>
          <div className="text-xs text-muted-foreground mt-2">12 pending dispatch</div>
        </Card>

        <Card className="bg-card/40 border-white/5 p-6 shadow-sm">
          <div className="flex items-center gap-4 mb-2">
            <AlertCircle className="text-rose-400" size={24} />
            <div className="text-sm font-medium text-muted-foreground">Support Tickets</div>
          </div>
          <div className="text-3xl font-bold">3</div>
          <div className="text-xs text-rose-400 mt-2">Requires immediate attention</div>
        </Card>
      </div>
      
      <div className="bg-card/40 border border-white/5 rounded-xl p-6">
        <h2 className="text-xl font-semibold mb-6">Recent Platform Activity</h2>
        <div className="text-sm text-muted-foreground text-center py-12">
          Data tables will be populated here via Supabase real-time subscriptions.
        </div>
      </div>
    </div>
  );
}
