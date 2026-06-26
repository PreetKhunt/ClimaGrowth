"use client";

import { useState } from "react";
import { BookOpen, PlayCircle, Award, Star, Clock, CheckCircle, X, ChevronRight } from "lucide-react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

const courses = [
  {
    id: 1,
    title: "Mastering Drip Irrigation in Arid Regions",
    instructor: "Dr. Vikram Singh",
    level: "Intermediate",
    duration: "2h 45m",
    rating: 4.8,
    progress: 100,
    thumbnail: "https://images.unsplash.com/photo-1560493676-04071c5f467b?w=800&q=80"
  },
  {
    id: 2,
    title: "Organic Pest Control for Cash Crops",
    instructor: "Meera Patel",
    level: "Beginner",
    duration: "1h 15m",
    rating: 4.9,
    progress: 35,
    thumbnail: "https://images.unsplash.com/photo-1595804369792-74d306b3fa1d?w=800&q=80"
  },
  {
    id: 3,
    title: "Government Subsidy Application Masterclass",
    instructor: "Govt Agri-Dept",
    level: "All Levels",
    duration: "45m",
    rating: 4.5,
    progress: 0,
    thumbnail: "https://images.unsplash.com/photo-1589923188900-85dae523342b?w=800&q=80"
  }
];

export default function AcademyPage() {
  const [activeVideo, setActiveVideo] = useState<any>(null);

  return (
    <div className="p-8 max-w-7xl mx-auto space-y-8">
      {activeVideo && (
        <div className="fixed inset-0 z-50 bg-black/90 backdrop-blur-md flex items-center justify-center p-4 md:p-10">
          <div className="w-full max-w-5xl bg-card border border-white/10 rounded-2xl overflow-hidden flex flex-col shadow-2xl animate-in zoom-in-95">
            <div className="flex justify-between items-center p-4 border-b border-white/5">
              <h2 className="text-xl font-bold truncate pr-4">{activeVideo.title}</h2>
              <Button variant="ghost" size="icon" onClick={() => setActiveVideo(null)} className="shrink-0">
                <X size={24} />
              </Button>
            </div>
            <div className="aspect-video bg-black relative flex items-center justify-center">
              {/* Mock Video Player */}
              <img src={activeVideo.thumbnail} alt={activeVideo.title} className="absolute inset-0 w-full h-full object-cover opacity-40" />
              <div className="absolute inset-0 flex items-center justify-center">
                <div className="w-20 h-20 bg-primary/20 rounded-full flex items-center justify-center cursor-pointer hover:bg-primary/40 transition-colors border border-primary/50 group">
                  <PlayCircle size={40} className="text-primary group-hover:scale-110 transition-transform" />
                </div>
              </div>
              <div className="absolute bottom-0 left-0 right-0 p-4 bg-gradient-to-t from-black/90 to-transparent">
                <div className="w-full h-1 bg-white/20 rounded-full mb-4">
                  <div className="w-1/3 h-full bg-primary rounded-full relative">
                    <div className="absolute right-0 top-1/2 -translate-y-1/2 w-3 h-3 bg-white rounded-full shadow" />
                  </div>
                </div>
                <div className="flex justify-between text-xs font-medium text-white/70">
                  <span>14:20 / {activeVideo.duration}</span>
                  <div className="flex gap-4">
                    <span className="cursor-pointer hover:text-white">CC</span>
                    <span className="cursor-pointer hover:text-white">1080p</span>
                    <span className="cursor-pointer hover:text-white">Fullscreen</span>
                  </div>
                </div>
              </div>
            </div>
            <div className="p-6 bg-card/50 flex justify-between items-center">
              <div>
                <p className="text-sm text-muted-foreground mb-1">Instructor: {activeVideo.instructor}</p>
                <div className="flex items-center gap-4">
                  <span className="text-xs font-bold text-primary bg-primary/10 px-2 py-1 rounded-md">{activeVideo.level}</span>
                  <span className="text-xs font-bold text-amber-400 flex items-center gap-1"><Star size={14} className="fill-amber-400" /> {activeVideo.rating}</span>
                </div>
              </div>
              <Button className="gap-2 bg-primary text-primary-foreground"><CheckCircle size={16} /> Mark as Completed</Button>
            </div>
          </div>
        </div>
      )}

      <div className="flex justify-between items-end">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Learning Academy</h1>
          <p className="text-muted-foreground mt-1">Upgrade your farming skills with expert-led video courses and certifications.</p>
        </div>
        <div className="flex items-center gap-4">
          <div className="text-right">
            <div className="text-sm font-bold text-amber-400 flex items-center gap-1 justify-end"><Award size={16} /> Level 4 Master Farmer</div>
            <div className="text-xs text-muted-foreground">1,250 XP earned</div>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {courses.map(course => (
          <Card 
            key={course.id} 
            className="bg-card/40 border-white/5 overflow-hidden group cursor-pointer hover:bg-card/60 transition-all hover:border-primary/30 hover:shadow-[0_0_20px_rgba(0,255,136,0.1)]"
            onClick={() => setActiveVideo(course)}
          >
            <div className="h-48 relative overflow-hidden">
              <div className="absolute inset-0 bg-black/40 group-hover:bg-black/20 transition-colors z-10" />
              <img src={course.thumbnail} alt={course.title} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" />
              
              <div className="absolute inset-0 z-20 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                <div className="w-16 h-16 rounded-full bg-primary/90 text-primary-foreground flex items-center justify-center backdrop-blur-md shadow-2xl scale-75 group-hover:scale-100 transition-transform">
                  <PlayCircle size={32} />
                </div>
              </div>
              
              <div className="absolute bottom-3 right-3 z-20 bg-black/80 backdrop-blur-md text-white text-xs font-bold px-2 py-1 rounded flex items-center gap-1">
                <Clock size={12} /> {course.duration}
              </div>
            </div>
            
            <div className="p-6">
              <div className="flex justify-between items-start mb-2">
                <span className="text-xs font-bold text-primary bg-primary/10 px-2 py-1 rounded-md">{course.level}</span>
                <span className="text-xs font-bold text-amber-400 flex items-center gap-1"><Star size={12} className="fill-amber-400" /> {course.rating}</span>
              </div>
              
              <h3 className="font-bold text-lg mb-1 leading-tight group-hover:text-primary transition-colors">{course.title}</h3>
              <p className="text-sm text-muted-foreground mb-6">by {course.instructor}</p>
              
              <div className="space-y-2">
                <div className="flex justify-between text-xs text-muted-foreground">
                  <span>{course.progress === 100 ? 'Completed' : `${course.progress}% Completed`}</span>
                  {course.progress === 100 && <span className="text-primary flex items-center gap-1"><CheckCircle size={12}/> Certified</span>}
                </div>
                <div className="w-full h-1.5 rounded-full bg-black/40 overflow-hidden">
                  <div className={`h-full rounded-full transition-all duration-1000 ${course.progress === 100 ? 'bg-primary' : 'bg-blue-500'}`} style={{ width: `${course.progress}%` }} />
                </div>
              </div>
            </div>
          </Card>
        ))}
      </div>
      
      <Card className="p-8 bg-primary/10 border-primary/20 flex flex-col md:flex-row items-center justify-between gap-6">
        <div className="flex items-center gap-6">
          <div className="w-20 h-20 rounded-2xl bg-primary/20 text-primary flex items-center justify-center shrink-0">
            <BookOpen size={40} />
          </div>
          <div>
            <h2 className="text-2xl font-bold text-white mb-2">Become a Certified Smart Farmer</h2>
            <p className="text-sm text-muted-foreground max-w-2xl">Complete 5 more modules in the Precision Agriculture track to earn your government-recognized digital certificate, which boosts your subsidy match scores by 15%.</p>
          </div>
        </div>
        <Button className="shrink-0 gap-2">View Learning Tracks <ChevronRight size={16}/></Button>
      </Card>
    </div>
  );
}
