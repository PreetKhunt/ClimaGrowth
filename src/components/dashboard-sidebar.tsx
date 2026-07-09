"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { 
  LayoutDashboard, CloudRain, Sprout, ShoppingCart, 
  Settings, User, MessageSquare, Wrench, FileText,
  Map, Droplets, PieChart, Users, BookOpen, ShieldCheck, Warehouse, Landmark, LogOut
} from "lucide-react";
import { cn } from "@/lib/utils";
import { logout } from "@/actions/auth-actions";

const navigation = [
  { name: "Overview", href: "/dashboard", icon: LayoutDashboard, category: "Main" },
  { name: "AI Assistant", href: "/dashboard/chat", icon: MessageSquare, category: "Main" },
  
  { name: "Crop Planner", href: "/dashboard/planner", icon: FileText, category: "Intelligence" },
  { name: "Disease Detection", href: "/dashboard/disease", icon: ShieldCheck, category: "Intelligence" },
  { name: "Yield Prediction", href: "/dashboard/yield", icon: PieChart, category: "Intelligence" },
  { name: "Weather Maps", href: "/dashboard/weather", icon: CloudRain, category: "Intelligence" },
  
  { name: "Farm Management", href: "/dashboard/farms", icon: Map, category: "Operations" },
  { name: "Smart Irrigation", href: "/dashboard/irrigation", icon: Droplets, category: "Operations" },
  { name: "Harvest & Storage", href: "/dashboard/harvest", icon: Warehouse, category: "Operations" },
  { name: "Smart Tools", href: "/dashboard/tools", icon: Wrench, category: "Operations" },
  
  { name: "Agri-Market", href: "/dashboard/market", icon: ShoppingCart, category: "Commerce" },
  { name: "Govt Schemes", href: "/dashboard/schemes", icon: Landmark, category: "Commerce" },
  { name: "Finance & Loans", href: "/dashboard/finance", icon: PieChart, category: "Commerce" },
  
  { name: "Community", href: "/dashboard/community", icon: Users, category: "Learn" },
  { name: "Learning Academy", href: "/dashboard/academy", icon: BookOpen, category: "Learn" },
  
  { name: "Profile", href: "/dashboard/profile", icon: User, category: "Settings" },
  { name: "Settings", href: "/dashboard/settings", icon: Settings, category: "Settings" },
];

export function DashboardSidebar() {
  const pathname = usePathname();

  return (
    <aside className="flex h-full w-64 flex-col border-r border-white/5 bg-black/40 backdrop-blur-xl">
      <div className="flex h-16 shrink-0 items-center px-6">
        <Sprout className="h-6 w-6 text-primary mr-2" />
        <span className="text-xl font-bold tracking-tight text-white">Clima<span className="text-primary">Growth</span></span>
      </div>
      <div className="flex flex-1 flex-col overflow-y-auto px-4 py-4 space-y-6 custom-scrollbar">
        
        {["Main", "Intelligence", "Operations", "Commerce", "Learn", "Settings"].map((category) => (
          <div key={category}>
            <h3 className="px-2 text-xs font-semibold text-muted-foreground uppercase tracking-wider mb-2">{category}</h3>
            <div className="space-y-1">
              {navigation.filter(item => item.category === category).map((item) => {
                const isActive = pathname === item.href;
                return (
                  <Link
                    key={item.name}
                    href={item.href}
                    className={cn(
                      "group flex items-center rounded-md px-3 py-2 text-sm font-medium transition-all",
                      isActive
                        ? "bg-primary/10 text-primary"
                        : "text-muted-foreground hover:bg-white/5 hover:text-foreground"
                    )}
                  >
                    <item.icon
                      className={cn(
                        "mr-3 h-5 w-5 shrink-0 transition-colors",
                        isActive ? "text-primary" : "text-muted-foreground group-hover:text-foreground"
                      )}
                    />
                    {item.name}
                  </Link>
                );
              })}
            </div>
          </div>
        ))}
        
      </div>
      
      <div className="p-4 border-t border-white/5">
        <form action={logout}>
          <button type="submit" className="w-full flex items-center gap-3 bg-white/5 p-3 rounded-lg border border-white/5 cursor-pointer hover:bg-white/10 transition text-left">
            <div className="w-10 h-10 rounded-full bg-red-500/20 flex items-center justify-center text-red-500 font-bold shrink-0">
              <LogOut className="w-5 h-5" />
            </div>
            <div className="flex flex-col">
              <span className="text-sm font-medium leading-none mb-1 text-white">Sign Out</span>
              <span className="text-xs text-muted-foreground leading-none">End your session</span>
            </div>
          </button>
        </form>
      </div>
    </aside>
  );
}
