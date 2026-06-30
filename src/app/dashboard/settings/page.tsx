/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable react/no-unescaped-entities */
/* eslint-disable @typescript-eslint/no-unused-vars */
/* eslint-disable @typescript-eslint/no-require-imports */
"use client";

import { useState } from "react";
import { useTheme } from "next-themes";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { createClient } from "@/lib/supabase/client";
import { Loader2 } from "lucide-react";

export default function SettingsPage() {
  const { theme, setTheme } = useTheme();
  const supabase = createClient();
  
  const [loading, setLoading] = useState(false);
  const [activeLanguage, setActiveLanguage] = useState("English");
  
  const [password, setPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [isUpdatingPassword, setIsUpdatingPassword] = useState(false);
  
  const handleUpdatePassword = async () => {
    if (!newPassword || newPassword.length < 6) {
      alert("New password must be at least 6 characters.");
      return;
    }
    
    setIsUpdatingPassword(true);
    try {
      const { error } = await supabase.auth.updateUser({
        password: newPassword
      });
      
      if (error) throw new Error(error.message);
      
      alert("Password updated successfully!");
      setPassword("");
      setNewPassword("");
    } catch (err: any) {
      alert(err.message || "Failed to update password");
    } finally {
      setIsUpdatingPassword(false);
    }
  };

  return (
    <div className="p-8 max-w-4xl mx-auto">
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
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div 
              className={`p-4 border rounded-xl cursor-pointer transition-all ${activeLanguage === "English" ? "bg-primary/10 border-primary" : "bg-black/20 border-white/5 hover:border-white/20"}`}
              onClick={() => setActiveLanguage("English")}
            >
              <div className="font-semibold">English</div>
              <div className="text-sm text-muted-foreground mt-1">System Default</div>
            </div>
            <div 
              className={`p-4 border rounded-xl cursor-pointer transition-all ${activeLanguage === "Hindi" ? "bg-primary/10 border-primary" : "bg-black/20 border-white/5 hover:border-white/20"}`}
              onClick={() => setActiveLanguage("Hindi")}
            >
              <div className="font-semibold">हिन्दी (Hindi)</div>
              <div className="text-sm text-muted-foreground mt-1">Translation applied locally</div>
            </div>
            <div 
              className={`p-4 border rounded-xl cursor-pointer transition-all ${activeLanguage === "Gujarati" ? "bg-primary/10 border-primary" : "bg-black/20 border-white/5 hover:border-white/20"}`}
              onClick={() => setActiveLanguage("Gujarati")}
            >
              <div className="font-semibold">ગુજરાતી (Gujarati)</div>
              <div className="text-sm text-muted-foreground mt-1">Translation applied locally</div>
            </div>
          </div>
        </div>

        <div className="bg-card/40 border border-white/5 rounded-xl p-6">
          <h2 className="text-xl font-semibold mb-4">Security</h2>
          <div className="space-y-4 max-w-sm">
            <div>
              <label className="block text-sm font-medium mb-1">Current Password (optional to verify)</label>
              <Input 
                type="password" 
                placeholder="••••••••" 
                className="w-full bg-background/50 border-white/10" 
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">New Password</label>
              <Input 
                type="password" 
                placeholder="••••••••" 
                className="w-full bg-background/50 border-white/10"
                value={newPassword}
                onChange={(e) => setNewPassword(e.target.value)} 
              />
            </div>
            <Button 
              onClick={handleUpdatePassword} 
              disabled={isUpdatingPassword || !newPassword}
              className="w-full"
            >
              {isUpdatingPassword ? <Loader2 className="w-4 h-4 mr-2 animate-spin" /> : null}
              {isUpdatingPassword ? "Updating..." : "Update Password"}
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}
