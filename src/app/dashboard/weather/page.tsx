"use client";

import { CloudSun, Droplets, Wind, Sun, CloudRain } from "lucide-react";
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from "recharts";
import { Card } from "@/components/ui/card";

const forecastData = [
  { time: "06:00", temp: 18, humidity: 82 },
  { time: "09:00", temp: 22, humidity: 75 },
  { time: "12:00", temp: 26, humidity: 65 },
  { time: "15:00", temp: 28, humidity: 60 },
  { time: "18:00", temp: 25, humidity: 68 },
  { time: "21:00", temp: 21, humidity: 78 },
];

export default function WeatherDashboard() {
  return (
    <div className="p-8 max-w-6xl">
      <div className="mb-8 flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Weather Intelligence</h1>
          <p className="text-muted-foreground mt-1">Hyper-local forecast for Green Acres Farm</p>
        </div>
        <div className="bg-primary/10 text-primary px-4 py-2 rounded-lg font-medium inline-flex items-center gap-2 w-fit">
          <CloudSun size={20} />
          <span>Real-time Sync Active</span>
        </div>
      </div>

      <div className="grid gap-6 md:grid-cols-3 mb-8">
        <Card className="col-span-1 bg-gradient-to-br from-blue-500/20 to-purple-500/20 border-white/10 p-6 flex flex-col justify-between">
          <div className="flex justify-between items-start">
            <div>
              <div className="text-sm font-medium text-white/80">Current Temperature</div>
              <div className="text-6xl font-bold mt-2">24°</div>
              <div className="text-lg font-medium text-white/90 mt-1">Partly Cloudy</div>
            </div>
            <CloudSun size={48} className="text-blue-400" />
          </div>
          <div className="mt-8 flex gap-4 text-sm text-white/70">
            <span>H: 28°</span>
            <span>L: 16°</span>
          </div>
        </Card>

        <Card className="col-span-1 md:col-span-2 bg-card/40 border-white/5 p-6">
          <h3 className="text-lg font-semibold mb-4">24-Hour Forecast</h3>
          <div className="h-[200px] w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={forecastData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                <defs>
                  <linearGradient id="colorTemp" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#4CC9F0" stopOpacity={0.3}/>
                    <stop offset="95%" stopColor="#4CC9F0" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#ffffff10" vertical={false} />
                <XAxis dataKey="time" stroke="#ffffff50" fontSize={12} tickLine={false} axisLine={false} />
                <YAxis stroke="#ffffff50" fontSize={12} tickLine={false} axisLine={false} />
                <Tooltip 
                  contentStyle={{ backgroundColor: '#111', borderColor: '#333', borderRadius: '8px' }}
                  itemStyle={{ color: '#fff' }}
                />
                <Area type="monotone" dataKey="temp" stroke="#4CC9F0" strokeWidth={3} fillOpacity={1} fill="url(#colorTemp)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </Card>
      </div>

      <h3 className="text-xl font-semibold mb-4">Atmospheric Conditions</h3>
      <div className="grid gap-6 md:grid-cols-4">
        <Card className="bg-card/40 border-white/5 p-6 flex flex-col items-center justify-center text-center">
          <Droplets className="text-blue-400 mb-3" size={32} />
          <div className="text-sm font-medium text-muted-foreground">Humidity</div>
          <div className="text-2xl font-bold mt-1">65%</div>
        </Card>
        <Card className="bg-card/40 border-white/5 p-6 flex flex-col items-center justify-center text-center">
          <Wind className="text-teal-400 mb-3" size={32} />
          <div className="text-sm font-medium text-muted-foreground">Wind Speed</div>
          <div className="text-2xl font-bold mt-1">12 km/h</div>
        </Card>
        <Card className="bg-card/40 border-white/5 p-6 flex flex-col items-center justify-center text-center">
          <CloudRain className="text-indigo-400 mb-3" size={32} />
          <div className="text-sm font-medium text-muted-foreground">Precipitation</div>
          <div className="text-2xl font-bold mt-1">0 mm</div>
        </Card>
        <Card className="bg-card/40 border-white/5 p-6 flex flex-col items-center justify-center text-center">
          <Sun className="text-amber-400 mb-3" size={32} />
          <div className="text-sm font-medium text-muted-foreground">UV Index</div>
          <div className="text-2xl font-bold mt-1">High (7)</div>
        </Card>
      </div>
    </div>
  );
}
