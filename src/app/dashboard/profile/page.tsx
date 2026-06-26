import { Button } from "@/components/ui/button";

export default function ProfilePage() {
  return (
    <div className="p-8 max-w-4xl">
      <div className="mb-8">
        <h1 className="text-3xl font-bold tracking-tight">Profile</h1>
        <p className="text-muted-foreground mt-1">Manage your personal information and farm details.</p>
      </div>

      <div className="grid gap-8">
        <div className="bg-card/40 border border-white/5 rounded-xl p-6">
          <div className="flex items-center gap-6 mb-6">
            <div className="w-24 h-24 rounded-full bg-primary/20 flex items-center justify-center text-primary text-3xl font-bold">
              PF
            </div>
            <div>
              <h2 className="text-2xl font-semibold">Preet Farmer</h2>
              <p className="text-muted-foreground">preet@example.com</p>
              <Button variant="outline" size="sm" className="mt-2">Change Avatar</Button>
            </div>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium mb-1">Full Name</label>
              <input type="text" defaultValue="Preet Farmer" className="w-full border border-white/10 rounded-md px-3 py-2 text-sm bg-background/50" />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">Phone Number</label>
              <input type="tel" defaultValue="+91 98765 43210" className="w-full border border-white/10 rounded-md px-3 py-2 text-sm bg-background/50" />
            </div>
          </div>
          <Button className="mt-4">Save Changes</Button>
        </div>

        <div className="bg-card/40 border border-white/5 rounded-xl p-6">
          <h2 className="text-xl font-semibold mb-4">Farm Information</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium mb-1">Farm Name</label>
              <input type="text" defaultValue="Green Acres" className="w-full border border-white/10 rounded-md px-3 py-2 text-sm bg-background/50" />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">Primary Crop</label>
              <input type="text" defaultValue="Wheat" className="w-full border border-white/10 rounded-md px-3 py-2 text-sm bg-background/50" />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">Total Area (Acres)</label>
              <input type="number" defaultValue="124" className="w-full border border-white/10 rounded-md px-3 py-2 text-sm bg-background/50" />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">Soil Type</label>
              <select className="w-full border border-white/10 rounded-md px-3 py-2 text-sm bg-background/50">
                <option>Alluvial</option>
                <option>Black Soil</option>
                <option>Red Soil</option>
              </select>
            </div>
          </div>
          <Button className="mt-4">Update Farm Details</Button>
        </div>
      </div>
    </div>
  );
}
