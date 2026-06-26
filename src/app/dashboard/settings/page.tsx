"use client";

import { useTheme } from "next-themes";
import { Button } from "@/components/ui/button";

export default function SettingsPage() {
  const { theme, setTheme } = useTheme();

  return (
    <div className="p-8 max-w-4xl">
      <div className="mb-8">
        <h1 className="text-3xl font-bold tracking-tight">Settings</h1>
        <p className="text-muted-foreground mt-1">Manage your account preferences and application settings.</p>
      </div>

      <div className="space-y-8">
        <div className="bg-card/40 border border-white/5 rounded-xl p-6">
          <h2 className="text-xl font-semibold mb-4">Appearance</h2>
          <div className="flex gap-4">
            <Button variant={theme === "light" ? "default" : "outline"} onClick={() => setTheme("light")}>
              Light Mode
            </Button>
            <Button variant={theme === "dark" ? "default" : "outline"} onClick={() => setTheme("dark")}>
              Dark Mode
            </Button>
            <Button variant={theme === "system" ? "default" : "outline"} onClick={() => setTheme("system")}>
              System
            </Button>
          </div>
        </div>

        <div className="bg-card/40 border border-white/5 rounded-xl p-6">
          <h2 className="text-xl font-semibold mb-4">Language</h2>
          <div className="flex gap-4">
            <Button variant="default">English (Default)</Button>
            <Button variant="outline">Hindi (Coming Soon)</Button>
            <Button variant="outline">Gujarati (Coming Soon)</Button>
          </div>
        </div>

        <div className="bg-card/40 border border-white/5 rounded-xl p-6">
          <h2 className="text-xl font-semibold mb-4">Security</h2>
          <div className="space-y-4 max-w-sm">
            <div>
              <label className="block text-sm font-medium mb-1">Current Password</label>
              <input type="password" placeholder="••••••••" className="w-full border border-white/10 rounded-md px-3 py-2 text-sm bg-background/50" />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">New Password</label>
              <input type="password" placeholder="••••••••" className="w-full border border-white/10 rounded-md px-3 py-2 text-sm bg-background/50" />
            </div>
            <Button>Update Password</Button>
          </div>
        </div>
      </div>
    </div>
  );
}
