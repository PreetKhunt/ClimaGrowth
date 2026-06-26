"use client";

import { useState } from "react";
import { 
  AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip as RechartsTooltip, ResponsiveContainer,
  BarChart, Bar, PieChart, Pie, Cell, Legend
} from "recharts";
import { IndianRupee, TrendingUp, PiggyBank, Receipt, ArrowUpRight, ArrowDownRight, Wallet } from "lucide-react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

const revenueData = [
  { month: "Jan", revenue: 15000, expense: 8000 },
  { month: "Feb", revenue: 20000, expense: 9500 },
  { month: "Mar", revenue: 45000, expense: 12000 }, // Harvest
  { month: "Apr", revenue: 12000, expense: 15000 }, // Sowing
  { month: "May", revenue: 18000, expense: 11000 },
  { month: "Jun", revenue: 30000, expense: 10000 },
];

const expenseBreakdown = [
  { name: "Fertilizers", value: 35000, color: "#00FF88" },
  { name: "Labor", value: 45000, color: "#4CC9F0" },
  { name: "Seeds", value: 15000, color: "#7B61FF" },
  { name: "Irrigation", value: 20000, color: "#F72585" },
];

export default function FinanceDashboardPage() {
  const [activeTab, setActiveTab] = useState("overview");

  return (
    <div className="p-8 max-w-7xl mx-auto space-y-8">
      <div className="flex justify-between items-end">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">AI Financial Advisor</h1>
          <p className="text-muted-foreground mt-1">Track revenue, optimize expenses, and manage farm loans.</p>
        </div>
        <Button className="bg-primary text-primary-foreground gap-2"><Receipt size={16} /> Generate Tax Report</Button>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card className="p-6 bg-card/40 border-white/5 relative overflow-hidden group">
          <div className="absolute inset-0 bg-gradient-to-br from-primary/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity" />
          <div className="flex justify-between items-start mb-4">
            <div className="w-10 h-10 rounded-xl bg-primary/20 text-primary flex items-center justify-center">
              <IndianRupee size={20} />
            </div>
            <div className="flex items-center text-xs font-medium text-primary bg-primary/10 px-2 py-1 rounded-md">
              <ArrowUpRight size={14} className="mr-1" /> +12.5%
            </div>
          </div>
          <h3 className="text-muted-foreground text-sm font-medium mb-1">Total Revenue (YTD)</h3>
          <div className="text-3xl font-bold">₹1,40,000</div>
        </Card>
        
        <Card className="p-6 bg-card/40 border-white/5 relative overflow-hidden group">
          <div className="flex justify-between items-start mb-4">
            <div className="w-10 h-10 rounded-xl bg-rose-500/20 text-rose-400 flex items-center justify-center">
              <Wallet size={20} />
            </div>
            <div className="flex items-center text-xs font-medium text-rose-400 bg-rose-500/10 px-2 py-1 rounded-md">
              <ArrowDownRight size={14} className="mr-1" /> -4.2%
            </div>
          </div>
          <h3 className="text-muted-foreground text-sm font-medium mb-1">Total Expenses</h3>
          <div className="text-3xl font-bold text-white">₹1,15,000</div>
        </Card>

        <Card className="p-6 bg-card/40 border-white/5 relative overflow-hidden group">
          <div className="flex justify-between items-start mb-4">
            <div className="w-10 h-10 rounded-xl bg-blue-500/20 text-blue-400 flex items-center justify-center">
              <PiggyBank size={20} />
            </div>
          </div>
          <h3 className="text-muted-foreground text-sm font-medium mb-1">Net Profit</h3>
          <div className="text-3xl font-bold text-blue-400">₹25,000</div>
        </Card>

        <Card className="p-6 bg-card/40 border-white/5 relative overflow-hidden group">
          <div className="flex justify-between items-start mb-4">
            <div className="w-10 h-10 rounded-xl bg-amber-500/20 text-amber-400 flex items-center justify-center">
              <TrendingUp size={20} />
            </div>
          </div>
          <h3 className="text-muted-foreground text-sm font-medium mb-1">Active Loans</h3>
          <div className="text-3xl font-bold text-amber-400">₹50,000</div>
        </Card>
      </div>

      {/* Main Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <Card className="lg:col-span-2 p-6 bg-card/40 border-white/5">
          <h3 className="text-lg font-bold mb-6">Revenue vs Expenses</h3>
          <div className="h-[300px] w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={revenueData}>
                <defs>
                  <linearGradient id="colorRev" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#00FF88" stopOpacity={0.3} />
                    <stop offset="95%" stopColor="#00FF88" stopOpacity={0} />
                  </linearGradient>
                  <linearGradient id="colorExp" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#F72585" stopOpacity={0.3} />
                    <stop offset="95%" stopColor="#F72585" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#ffffff10" vertical={false} />
                <XAxis dataKey="month" stroke="#ffffff50" axisLine={false} tickLine={false} />
                <YAxis stroke="#ffffff50" axisLine={false} tickLine={false} tickFormatter={(v) => `₹${v/1000}k`} />
                <RechartsTooltip 
                  contentStyle={{ backgroundColor: "#050505", borderColor: "#ffffff20", borderRadius: "8px" }}
                  itemStyle={{ color: "#fff" }}
                />
                <Area type="monotone" dataKey="revenue" stroke="#00FF88" strokeWidth={3} fillOpacity={1} fill="url(#colorRev)" />
                <Area type="monotone" dataKey="expense" stroke="#F72585" strokeWidth={3} fillOpacity={1} fill="url(#colorExp)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </Card>

        <Card className="p-6 bg-card/40 border-white/5">
          <h3 className="text-lg font-bold mb-6">Expense Breakdown</h3>
          <div className="h-[250px] w-full">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie data={expenseBreakdown} cx="50%" cy="50%" innerRadius={60} outerRadius={80} paddingAngle={5} dataKey="value" stroke="none">
                  {expenseBreakdown.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <RechartsTooltip 
                  contentStyle={{ backgroundColor: "#050505", borderColor: "#ffffff20", borderRadius: "8px" }}
                />
              </PieChart>
            </ResponsiveContainer>
          </div>
          <div className="grid grid-cols-2 gap-4 mt-4">
            {expenseBreakdown.map(item => (
              <div key={item.name} className="flex items-center gap-2">
                <div className="w-3 h-3 rounded-full shrink-0" style={{ backgroundColor: item.color }} />
                <div className="text-xs text-muted-foreground truncate">{item.name}</div>
              </div>
            ))}
          </div>
        </Card>
      </div>
      
      {/* AI Recommendations */}
      <Card className="p-6 bg-primary/5 border-primary/20">
        <h3 className="text-lg font-bold text-primary mb-4 flex items-center gap-2">
          <SparklesIcon size={18} /> AI Financial Insights
        </h3>
        <div className="grid md:grid-cols-2 gap-6">
          <div className="bg-black/20 p-4 rounded-xl border border-white/5">
            <h4 className="font-semibold mb-2">High Labor Costs Detected</h4>
            <p className="text-sm text-muted-foreground">Your labor expenses ($45,000) are 15% higher than the regional average for Wheat farms of this size. Consider renting mechanized harvesters for the upcoming season to optimize costs.</p>
          </div>
          <div className="bg-black/20 p-4 rounded-xl border border-white/5">
            <h4 className="font-semibold mb-2">Subsidy Eligibility</h4>
            <p className="text-sm text-muted-foreground">Based on your recent Drip Irrigation purchase, you are eligible for the PMKSY Scheme which offers a 55% subsidy. You have 14 days left to file the claim.</p>
            <Button variant="link" className="px-0 h-auto text-primary mt-2">Apply Now →</Button>
          </div>
        </div>
      </Card>
    </div>
  );
}

function SparklesIcon(props: any) {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <path d="M9.937 15.5A2 2 0 0 0 8.5 14.063l-6.135-1.582a.5.5 0 0 1 0-.962L8.5 9.936A2 2 0 0 0 9.937 8.5l1.582-6.135a.5.5 0 0 1 .963 0L14.063 8.5A2 2 0 0 0 15.5 9.937l6.135 1.581a.5.5 0 0 1 0 .964L15.5 14.063a2 2 0 0 0-1.437 1.437l-1.582 6.135a.5.5 0 0 1-.963 0z"/>
      <path d="M20 3v4"/>
      <path d="M22 5h-4"/>
      <path d="M4 17v2"/>
      <path d="M5 18H3"/>
    </svg>
  );
}
