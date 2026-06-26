"use client";

import { Landmark, FileText, CheckCircle2, ChevronRight, Filter } from "lucide-react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

const schemes = [
  {
    id: 1,
    title: "Pradhan Mantri Fasal Bima Yojana (PMFBY)",
    description: "Crop insurance scheme that provides financial support to farmers in the event of crop failure due to natural calamities, pests & diseases.",
    eligibility: ["All farmers growing notified crops in notified areas", "Tenant farmers are eligible"],
    subsidy: "Maximum premium 2% for Kharif, 1.5% for Rabi",
    deadline: "15th July 2026",
    match: 98
  },
  {
    id: 2,
    title: "PM KISAN Samman Nidhi",
    description: "Income support scheme providing ₹6,000 per year in three equal installments to all landholding farmer families.",
    eligibility: ["Must hold cultivable land", "Valid Aadhaar Card", "Bank Account linked to Aadhaar"],
    subsidy: "₹6,000/year direct bank transfer",
    deadline: "Open All Year",
    match: 100
  },
  {
    id: 3,
    title: "Pradhan Mantri Krishi Sinchayee Yojana (PMKSY)",
    description: "Subsidy for installing micro-irrigation systems (drip/sprinkler) to improve water use efficiency ('Per Drop More Crop').",
    eligibility: ["Small and marginal farmers", "Must have water source"],
    subsidy: "Up to 55% subsidy on installation costs",
    deadline: "30th Sept 2026",
    match: 85
  }
];

export default function GovtSchemesPage() {
  return (
    <div className="p-8 max-w-7xl mx-auto space-y-8">
      <div className="flex justify-between items-end">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Government Schemes</h1>
          <p className="text-muted-foreground mt-1">AI-matched subsidies and grants based on your farm profile.</p>
        </div>
        <Button variant="outline" className="gap-2"><Filter size={16} /> Filter by State</Button>
      </div>

      {/* AI Profile Match Header */}
      <Card className="p-6 bg-primary/10 border-primary/20 flex flex-col md:flex-row items-center gap-6">
        <div className="w-16 h-16 rounded-full bg-primary/20 text-primary flex items-center justify-center shrink-0">
          <Landmark size={32} />
        </div>
        <div>
          <h2 className="text-xl font-bold text-white mb-2">3 Highly Relevant Schemes Found</h2>
          <p className="text-sm text-muted-foreground">Based on your profile (5 Acres, Cotton/Wheat, Gujarat), our AI has filtered 42 national and state schemes down to the ones you are highly likely to qualify for right now.</p>
        </div>
      </Card>

      <div className="grid gap-6">
        {schemes.map(scheme => (
          <Card key={scheme.id} className="p-6 bg-card/40 border-white/5 group hover:bg-card/60 transition-all">
            <div className="flex flex-col md:flex-row gap-6">
              
              <div className="flex-1">
                <div className="flex items-center gap-3 mb-2">
                  <h3 className="text-xl font-bold text-white">{scheme.title}</h3>
                  <div className="px-2 py-0.5 bg-primary/20 text-primary text-xs font-bold rounded-full border border-primary/30 flex items-center gap-1">
                    <CheckCircle2 size={12} /> {scheme.match}% Match
                  </div>
                </div>
                <p className="text-sm text-muted-foreground mb-6 max-w-3xl">{scheme.description}</p>
                
                <div className="grid md:grid-cols-2 gap-6">
                  <div>
                    <h4 className="text-xs font-semibold text-white uppercase tracking-wider mb-2">Eligibility Criteria</h4>
                    <ul className="space-y-1">
                      {scheme.eligibility.map((req, i) => (
                        <li key={i} className="text-sm text-muted-foreground flex items-start gap-2">
                          <div className="w-1.5 h-1.5 rounded-full bg-primary/50 mt-1.5 shrink-0" /> {req}
                        </li>
                      ))}
                    </ul>
                  </div>
                  <div>
                    <h4 className="text-xs font-semibold text-white uppercase tracking-wider mb-2">Key Benefits</h4>
                    <div className="text-sm font-medium text-amber-400 bg-amber-500/10 border border-amber-500/20 p-2 rounded-md inline-block">
                      {scheme.subsidy}
                    </div>
                  </div>
                </div>
              </div>

              <div className="w-full md:w-64 shrink-0 flex flex-col justify-between bg-black/20 p-4 rounded-xl border border-white/5">
                <div>
                  <div className="text-xs text-muted-foreground mb-1">Application Deadline</div>
                  <div className="font-semibold text-white mb-4">{scheme.deadline}</div>
                  
                  <div className="text-xs text-muted-foreground mb-1">Required Docs</div>
                  <div className="flex gap-2">
                    <div className="w-8 h-8 rounded bg-white/5 flex items-center justify-center text-muted-foreground" title="Aadhaar Card"><FileText size={14} /></div>
                    <div className="w-8 h-8 rounded bg-white/5 flex items-center justify-center text-muted-foreground" title="Land Records (7/12)"><FileText size={14} /></div>
                    <div className="w-8 h-8 rounded bg-white/5 flex items-center justify-center text-muted-foreground" title="Bank Passbook"><FileText size={14} /></div>
                  </div>
                </div>
                
                <Button className="w-full mt-6 gap-2" onClick={() => window.open('https://pmkisan.gov.in/', '_blank')}>Apply Online <ChevronRight size={16} /></Button>
              </div>

            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}
