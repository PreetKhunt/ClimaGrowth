 
/* eslint-disable react/no-unescaped-entities */
 
 
 
"use client";

import { motion } from "framer-motion";
import Link from "next/link";
import { ArrowRight, Leaf, CloudSun, Droplets, LineChart, Sparkles } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";

export default function Home() {
  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: { staggerChildren: 0.2 },
    },
  };

  const itemVariants = {
    hidden: { y: 20, opacity: 0 },
    visible: {
      y: 0,
      opacity: 1,
      transition: { duration: 0.5, ease: "easeOut" as const },
    },
  };

  return (
    <div className="relative min-h-screen overflow-hidden flex flex-col">
      {/* Background Ambient Glow */}
      <div className="absolute inset-0 z-0 overflow-hidden pointer-events-none">
        <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] rounded-full bg-primary/20 blur-[120px]" />
        <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] rounded-full bg-blue-500/10 blur-[120px]" />
      </div>

      {/* Global Navigation Header (Simplified for Landing Page) */}
      <header className="relative z-10 flex items-center justify-between px-8 py-6 border-b border-white/5 bg-background/50 backdrop-blur-md">
        <div className="flex items-center gap-2">
          <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary/20 text-primary">
            <Leaf size={18} />
          </div>
          <span className="font-semibold text-lg tracking-tight">ClimaGrowth</span>
        </div>
        <nav className="flex items-center gap-4">
          <Link href="/login" className="text-sm font-medium text-muted-foreground hover:text-foreground transition-colors">
            Sign In
          </Link>
          <Link href="/register">
            <Button className="rounded-full px-6">Get Started</Button>
          </Link>
        </nav>
      </header>

      {/* Hero Section */}
      <main className="relative z-10 flex-1 flex flex-col items-center justify-center px-4 pt-20 pb-32">
        <motion.div
          variants={containerVariants}
          initial="hidden"
          animate="visible"
          className="max-w-4xl w-full text-center space-y-8"
        >
          <motion.div variants={itemVariants} className="inline-flex items-center gap-2 px-3 py-1 rounded-full border border-primary/20 bg-primary/10 text-primary text-sm font-medium">
            <Sparkles size={14} />
            <span>ClimaGrowth Web 2.0 is now live</span>
          </motion.div>

          <motion.h1 variants={itemVariants} className="text-5xl md:text-7xl font-bold tracking-tighter bg-clip-text text-transparent bg-gradient-to-b from-foreground to-foreground/60">
            Precision Agriculture, <br /> Engineered for Growth.
          </motion.h1>

          <motion.p variants={itemVariants} className="text-lg md:text-xl text-muted-foreground max-w-2xl mx-auto leading-relaxed">
            Harness real-time weather data, advanced soil analytics, and AI-driven insights to maximize your farm's yield and profitability.
          </motion.p>

          <motion.div variants={itemVariants} className="flex items-center justify-center gap-4 pt-4">
            <Link href="/register">
              <Button size="lg" className="rounded-full px-8 h-12 text-base gap-2 group">
                Start Free Trial
                <ArrowRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
              </Button>
            </Link>
            <Link href="/login">
              <Button size="lg" variant="outline" className="rounded-full px-8 h-12 text-base bg-transparent border-white/10 hover:bg-white/5">
                Explore Dashboard
              </Button>
            </Link>
          </motion.div>
        </motion.div>

        {/* Feature Highlights Showcase */}
        <motion.div 
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.6, duration: 0.8, ease: "easeOut" }}
          className="w-full max-w-6xl mt-24 grid grid-cols-1 md:grid-cols-3 gap-6"
        >
          <Card className="bg-card/40 backdrop-blur-md border-white/5 p-6 hover:bg-card/60 transition-colors">
            <div className="h-12 w-12 rounded-xl bg-blue-500/20 text-blue-400 flex items-center justify-center mb-6">
              <CloudSun size={24} />
            </div>
            <h3 className="text-lg font-medium mb-2">Hyper-Local Weather</h3>
            <p className="text-muted-foreground text-sm leading-relaxed">
              Real-time atmospheric data and precision forecasting tailored exactly to your field's coordinates.
            </p>
          </Card>

          <Card className="bg-card/40 backdrop-blur-md border-white/5 p-6 hover:bg-card/60 transition-colors">
            <div className="h-12 w-12 rounded-xl bg-amber-500/20 text-amber-400 flex items-center justify-center mb-6">
              <Droplets size={24} />
            </div>
            <h3 className="text-lg font-medium mb-2">Soil Health Analytics</h3>
            <p className="text-muted-foreground text-sm leading-relaxed">
              Monitor NPK levels, moisture indices, and organic matter to perfectly balance your soil's chemistry.
            </p>
          </Card>

          <Card className="bg-card/40 backdrop-blur-md border-white/5 p-6 hover:bg-card/60 transition-colors">
            <div className="h-12 w-12 rounded-xl bg-primary/20 text-primary flex items-center justify-center mb-6">
              <LineChart size={24} />
            </div>
            <h3 className="text-lg font-medium mb-2">Smart Calculators</h3>
            <p className="text-muted-foreground text-sm leading-relaxed">
              From fertilizer optimization to profit forecasting, our suite of smart tools covers all your needs.
            </p>
          </Card>
        </motion.div>
      </main>
    </div>
  );
}
