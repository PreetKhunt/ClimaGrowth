"use client";

import { BookOpen, PlayCircle, Award, Star, Clock, CheckCircle } from "lucide-react";
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
  return (
    <div className="p-8 max-w-7xl mx-auto space-y-8">
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
          <Card key={course.id} className="bg-card/40 border-white/5 overflow-hidden group cursor-pointer hover:bg-card/60 transition-all">
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
        <Button className="shrink-0">View Learning Tracks</Button>
      </Card>
    </div>
  );
}
