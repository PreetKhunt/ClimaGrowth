/* eslint-disable @typescript-eslint/no-explicit-any */
 
/* eslint-disable @next/next/no-img-element */
 
 
"use client";

import { useState, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { ShieldCheck, UploadCloud, AlertTriangle, Syringe, MapPin, Search } from "lucide-react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

export default function DiseaseDetectionPage() {
  const [file, setFile] = useState<File | null>(null);
  const [preview, setPreview] = useState<string | null>(null);
  const [isScanning, setIsScanning] = useState(false);
  const [result, setResult] = useState<any>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      const selectedFile = e.target.files[0];
      setFile(selectedFile);
      setPreview(URL.createObjectURL(selectedFile));
      setResult(null);
    }
  };

  const handleScan = () => {
    if (!file) return;
    setIsScanning(true);
    
    // Mock AI Scanning delay
    setTimeout(() => {
      setIsScanning(false);
      setResult({
        disease: "Cotton Leaf Curl Virus (CLCuV)",
        confidence: 94.5,
        symptoms: ["Upward/downward curling of leaves", "Thickened veins", "Stunted growth"],
        causes: "Transmitted primarily by the whitefly (Bemisia tabaci).",
        treatment: "Spray Neem Seed Kernel Extract (NSKE) 5% or Imidacloprid 17.8 SL @ 0.5 ml/litre of water.",
        expert: "Dr. Ramesh Patel (Agri-Clinic, 4.2km away)",
      });
    }, 3000);
  };

  return (
    <div className="p-8 max-w-4xl mx-auto">
      <div className="mb-8 text-center">
        <h1 className="text-3xl font-bold tracking-tight">Disease Detection Center</h1>
        <p className="text-muted-foreground mt-1 max-w-lg mx-auto">Upload a clear photo of the infected crop leaf. Our AI will instantly identify the disease and provide treatment.</p>
      </div>

      <div className="grid md:grid-cols-2 gap-8">
        {/* Upload & Preview Area */}
        <div className="space-y-6">
          <Card 
            className={`border-dashed border-2 relative overflow-hidden transition-all duration-300 ${preview ? 'border-white/10 bg-black/40' : 'border-white/20 bg-card/20 hover:bg-card/40 hover:border-primary/50 cursor-pointer'} aspect-square flex flex-col items-center justify-center`}
            onClick={() => !preview && fileInputRef.current?.click()}
          >
            <input type="file" ref={fileInputRef} onChange={handleFileUpload} className="hidden" accept="image/*" />
            
            {preview ? (
              <div className="w-full h-full relative group">
                <img src={preview} alt="Crop Leaf" className="w-full h-full object-cover opacity-80" />
                
                {/* Scanning Animation Overlay */}
                {isScanning && (
                  <motion.div 
                    initial={{ top: "0%" }} 
                    animate={{ top: "100%" }} 
                    transition={{ duration: 1.5, repeat: Infinity, repeatType: "reverse" }} 
                    className="absolute left-0 w-full h-1 bg-primary shadow-[0_0_20px_rgba(0,255,136,1)] z-10" 
                  />
                )}
                
                {!isScanning && !result && (
                  <div className="absolute inset-0 bg-black/50 flex flex-col items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                    <Button variant="outline" className="mb-2" onClick={() => { setFile(null); setPreview(null); }}>Change Image</Button>
                    <Button onClick={handleScan} className="bg-primary hover:bg-primary/90 text-primary-foreground gap-2"><Search size={16} /> Scan with AI</Button>
                  </div>
                )}
              </div>
            ) : (
              <div className="text-center p-6 pointer-events-none">
                <div className="w-16 h-16 rounded-full bg-white/5 flex items-center justify-center mx-auto mb-4 text-muted-foreground">
                  <UploadCloud size={32} />
                </div>
                <h3 className="font-semibold text-lg mb-1">Upload Photo</h3>
                <p className="text-sm text-muted-foreground">JPG, PNG up to 5MB</p>
              </div>
            )}
          </Card>
          
          {preview && !result && !isScanning && (
            <Button onClick={handleScan} className="w-full h-12 text-lg bg-primary hover:bg-primary/90 text-primary-foreground shadow-[0_0_15px_rgba(0,255,136,0.3)]">
              Analyze Image
            </Button>
          )}
          
          {isScanning && (
            <div className="text-center animate-pulse text-primary font-medium">
              AI Engine Analyzing Leaf Patterns...
            </div>
          )}
        </div>

        {/* Results Area */}
        <div className="h-full">
          <AnimatePresence>
            {!result ? (
              <motion.div 
                exit={{ opacity: 0, y: 10 }}
                className="h-full flex flex-col items-center justify-center text-center p-8 border border-white/5 bg-card/20 rounded-xl"
              >
                <ShieldCheck size={48} className="text-muted-foreground/30 mb-4" />
                <h3 className="text-lg font-medium text-muted-foreground">Awaiting Image</h3>
                <p className="text-sm text-muted-foreground/60 mt-2">Results will appear here after AI analysis.</p>
              </motion.div>
            ) : (
              <motion.div 
                initial={{ opacity: 0, x: 20 }} 
                animate={{ opacity: 1, x: 0 }} 
                className="space-y-4"
              >
                <Card className="bg-rose-500/10 border-rose-500/20 p-6 relative overflow-hidden">
                  <div className="absolute top-0 right-0 p-4">
                    <div className="w-12 h-12 rounded-full border-4 border-rose-500 flex items-center justify-center font-bold text-rose-500 text-sm">
                      {result.confidence}%
                    </div>
                  </div>
                  <h2 className="text-2xl font-bold text-rose-400 mb-1">{result.disease}</h2>
                  <p className="text-sm text-rose-200/70 mb-4">Detected with high confidence</p>
                  
                  <div className="space-y-1">
                    <div className="text-xs font-semibold uppercase tracking-wider text-rose-400/70">Causes</div>
                    <p className="text-sm text-rose-100">{result.causes}</p>
                  </div>
                </Card>
                
                <Card className="bg-card/40 border-white/5 p-6 space-y-4">
                  <div className="flex gap-3">
                    <AlertTriangle className="text-amber-400 shrink-0 mt-0.5" size={18} />
                    <div>
                      <h4 className="font-semibold text-sm mb-1 text-white">Observed Symptoms</h4>
                      <ul className="text-sm text-muted-foreground list-disc pl-4 space-y-1">
                        {result.symptoms.map((sym: string, i: number) => <li key={i}>{sym}</li>)}
                      </ul>
                    </div>
                  </div>
                  
                  <div className="w-full h-px bg-white/5" />
                  
                  <div className="flex gap-3">
                    <Syringe className="text-primary shrink-0 mt-0.5" size={18} />
                    <div>
                      <h4 className="font-semibold text-sm mb-1 text-white">Recommended Treatment</h4>
                      <p className="text-sm text-muted-foreground">{result.treatment}</p>
                      <Button variant="link" className="px-0 h-auto text-primary mt-2">Buy Treatment in Market →</Button>
                    </div>
                  </div>
                </Card>

                <Card className="bg-card/40 border-white/5 p-4 flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-full bg-blue-500/20 text-blue-400 flex items-center justify-center">
                      <MapPin size={18} />
                    </div>
                    <div>
                      <div className="font-medium text-sm">Nearby Expert Available</div>
                      <div className="text-xs text-muted-foreground">{result.expert}</div>
                    </div>
                  </div>
                  <Button variant="outline" size="sm">Contact</Button>
                </Card>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>
    </div>
  );
}
