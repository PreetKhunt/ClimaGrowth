 
/* eslint-disable react/no-unescaped-entities */
 
 
 
export default function DashboardOverview() {
  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold tracking-tight">Overview</h1>
        <p className="text-muted-foreground mt-1">Welcome back, Preet. Here's what's happening with your farm today.</p>
      </div>

      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
        <div className="rounded-xl border border-white/5 bg-card/40 p-6 shadow-sm">
          <div className="text-sm font-medium text-muted-foreground mb-2">Total Area</div>
          <div className="text-3xl font-bold">124 <span className="text-lg font-normal text-muted-foreground">Acres</span></div>
        </div>
        <div className="rounded-xl border border-white/5 bg-card/40 p-6 shadow-sm">
          <div className="text-sm font-medium text-muted-foreground mb-2">Active Crops</div>
          <div className="text-3xl font-bold">3</div>
        </div>
        <div className="rounded-xl border border-white/5 bg-card/40 p-6 shadow-sm">
          <div className="text-sm font-medium text-muted-foreground mb-2">Soil Health Score</div>
          <div className="text-3xl font-bold text-primary">87/100</div>
        </div>
        <div className="rounded-xl border border-white/5 bg-card/40 p-6 shadow-sm">
          <div className="text-sm font-medium text-muted-foreground mb-2">Today's Weather</div>
          <div className="text-3xl font-bold">24°C <span className="text-lg font-normal text-muted-foreground">Sunny</span></div>
        </div>
      </div>
    </div>
  );
}
