/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable react/no-unescaped-entities */
/* eslint-disable @typescript-eslint/no-require-imports */
"use client";

import { useState } from "react";
import { CheckCircle, X, ChevronRight, CheckSquare, Square, Loader2, PlayCircle, Clock, Star, Award, BookOpen } from "lucide-react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { updateLearningProgress } from "@/actions/academy-actions";

const courses = [
  {
    id: 1,
    title: "Mastering Drip Irrigation in Arid Regions",
    instructor: "Dr. Vikram Singh",
    level: "Intermediate",
    duration: "2h 45m",
    rating: 4.8,
    progress: 100,
    thumbnail: "https://images.unsplash.com/photo-1560493676-04071c5f467b?w=800&q=80",
    youtubeId: "78T3w7Yy-lY" // Example drip irrigation video
  },
  {
    id: 2,
    title: "Organic Pest Control for Cash Crops",
    instructor: "Meera Patel",
    level: "Beginner",
    duration: "1h 15m",
    rating: 4.9,
    progress: 35,
    thumbnail: "https://images.unsplash.com/photo-1595804369792-74d306b3fa1d?w=800&q=80",
    youtubeId: "2-dO2F-a-0o" // Example organic farming video
  },
  {
    id: 3,
    title: "Government Subsidy Application Masterclass",
    instructor: "Govt Agri-Dept",
    level: "All Levels",
    duration: "45m",
    rating: 4.5,
    progress: 0,
    thumbnail: "https://images.unsplash.com/photo-1589923188900-85dae523342b?w=800&q=80",
    youtubeId: "rN9j164qO4k" // Example govt scheme video
  }
];

export default function AcademyPage() {
  const [activeVideo, setActiveVideo] = useState<any>(null);
  const [completedTasks, setCompletedTasks] = useState<string[]>([]);
  const [isSaving, setIsSaving] = useState(false);
  const [videoError, setVideoError] = useState(false);

  const handleTaskToggle = (task: string) => {
    if (completedTasks.includes(task)) {
      setCompletedTasks(completedTasks.filter(t => t !== task));
    } else {
      setCompletedTasks([...completedTasks, task]);
    }
  };

  const markCompleted = async () => {
    if (!activeVideo) return;
    setIsSaving(true);
    try {
      const res = await updateLearningProgress({
        course_id: activeVideo.id.toString(),
        lesson_id: "lesson_1",
        status: 'completed',
        video_timestamp_seconds: 0
      });
      if (!res.success) throw new Error(res.error);
      
      alert("Lesson marked as complete!");
      setActiveVideo(null);
      setCompletedTasks([]);
    } catch (e: any) {
      console.error(e);
      alert(e.message || "Failed to save progress.");
    } finally {
      setIsSaving(false);
    }
  };

  const tasks = [
    "Watch the complete video introduction",
    "Review the setup checklist",
    "Complete the final quiz"
  ];

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
            <div className="aspect-video bg-black relative flex items-center justify-center overflow-hidden">
              {activeVideo.youtubeId && !videoError ? (
                <iframe 
                  className="w-full h-full"
                  src={`https://www.youtube.com/embed/${activeVideo.youtubeId}?autoplay=1&mute=0`} 
                  title={activeVideo.title} 
                  frameBorder="0" 
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                  allowFullScreen
                  onError={() => {
                    setVideoError(true);
                    window.open(`https://www.youtube.com/watch?v=${activeVideo.youtubeId}`, '_blank');
                  }}
                ></iframe>
              ) : (
                <>
                  <img src={activeVideo.thumbnail} alt={activeVideo.title} className="absolute inset-0 w-full h-full object-cover opacity-40" />
                  <div className="absolute inset-0 flex items-center justify-center flex-col gap-4">
                    <p className="text-white font-medium">Video could not be embedded automatically.</p>
                    <Button 
                      onClick={() => window.open(`https://www.youtube.com/watch?v=${activeVideo.youtubeId}`, '_blank')}
                      className="bg-amber-500 hover:bg-amber-600 text-black"
                    >
                      <PlayCircle className="mr-2" /> Open in YouTube
                    </Button>
                  </div>
                </>
              )}
            </div>
            
            {activeVideo.youtubeId && (
              <div className="bg-amber-500/10 border-b border-amber-500/20 px-6 py-2 flex justify-between items-center text-sm">
                <span className="text-amber-200">If the video isn't playing properly, you can watch it directly on YouTube.</span>
                <a 
                  href={`https://www.youtube.com/watch?v=${activeVideo.youtubeId}`} 
                  target="_blank" 
                  rel="noopener noreferrer"
                  className="text-amber-400 font-bold hover:underline flex items-center gap-1"
                >
                  Open in YouTube <PlayCircle size={14} />
                </a>
              </div>
            )}
            <div className="p-6 bg-card/50">
              <div className="mb-6">
                <h3 className="font-semibold text-lg mb-3 flex items-center gap-2">Lesson Tasks</h3>
                <div className="space-y-3">
                  {tasks.map((task, idx) => (
                    <div 
                      key={idx} 
                      className={`flex items-center gap-3 p-3 rounded-lg border cursor-pointer transition-colors ${completedTasks.includes(task) ? 'bg-primary/10 border-primary/30 text-primary' : 'bg-black/20 border-white/10 hover:border-white/30'}`}
                      onClick={() => handleTaskToggle(task)}
                    >
                      {completedTasks.includes(task) ? <CheckSquare className="text-primary" /> : <Square className="text-muted-foreground" />}
                      <span className={completedTasks.includes(task) ? 'line-through opacity-70' : ''}>{task}</span>
                    </div>
                  ))}
                </div>
              </div>
              <div className="flex justify-between items-center pt-4 border-t border-white/5">
                <div>
                  <p className="text-sm text-muted-foreground mb-1">Instructor: {activeVideo.instructor}</p>
                  <div className="flex items-center gap-4">
                    <span className="text-xs font-bold text-primary bg-primary/10 px-2 py-1 rounded-md">{activeVideo.level}</span>
                    <span className="text-xs font-bold text-amber-400 flex items-center gap-1"><Star size={14} className="fill-amber-400" /> {activeVideo.rating}</span>
                  </div>
                </div>
                <Button 
                  onClick={markCompleted}
                  disabled={isSaving || completedTasks.length < tasks.length}
                  className="gap-2 bg-primary text-primary-foreground disabled:bg-primary/30"
                >
                  {isSaving ? <Loader2 className="w-4 h-4 animate-spin" /> : <CheckCircle size={16} />} 
                  Mark as Completed
                </Button>
              </div>
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
