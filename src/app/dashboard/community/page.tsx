"use client";

import { useState, useEffect } from "react";
import { MessageSquare, Heart, Share2, Users, Flame, Plus, Loader2 } from "lucide-react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { createClient } from "@/lib/supabase/client";

export default function CommunityPage() {
  const supabase = createClient();
  const [posts, setPosts] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadPosts() {
      const { data, error } = await supabase
        .from('posts')
        .select('*, author:profiles(full_name, avatar_url, phone)')
        .order('created_at', { ascending: false });
        
      if (!error && data) {
        setPosts(data);
      }
      setLoading(false);
    }
    loadPosts();
  }, [supabase]);
  return (
    <div className="p-8 max-w-5xl mx-auto space-y-8">
      <div className="flex justify-between items-end">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Farmer Community</h1>
          <p className="text-muted-foreground mt-1">Connect, share experiences, and get advice from local farmers and experts.</p>
        </div>
        <Button className="gap-2 bg-primary text-primary-foreground"><Plus size={16} /> New Post</Button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
        
        {/* Main Feed */}
        <div className="lg:col-span-3 space-y-6">
          
          {/* Create Post Card */}
          <Card className="p-4 bg-card/40 border-white/5 flex gap-4">
            <img src="https://api.dicebear.com/7.x/avataaars/svg?seed=Me" alt="You" className="w-10 h-10 rounded-full bg-white/5" />
            <div className="flex-1">
              <input type="text" placeholder="Share an update or ask a question..." className="w-full bg-transparent border-none focus:outline-none text-white text-sm mt-2" />
              <div className="w-full h-px bg-white/10 my-3" />
              <div className="flex justify-between items-center">
                <div className="flex gap-2">
                  <Button variant="ghost" size="sm" className="text-muted-foreground hover:text-white h-8 px-2 text-xs">📷 Photo</Button>
                  <Button variant="ghost" size="sm" className="text-muted-foreground hover:text-white h-8 px-2 text-xs">📍 Location</Button>
                </div>
                <Button size="sm" className="h-8 bg-primary text-primary-foreground">Post</Button>
              </div>
            </div>
          </Card>

          {/* Posts */}
          {loading ? (
            <div className="flex justify-center py-12"><Loader2 className="animate-spin text-primary" /></div>
          ) : posts.length === 0 ? (
            <Card className="p-12 bg-card/40 border-white/5 flex flex-col items-center justify-center text-center">
              <MessageSquare size={48} className="text-muted-foreground mb-4" />
              <h3 className="text-xl font-bold mb-2">No Posts Yet</h3>
              <p className="text-muted-foreground mb-6 max-w-md">Be the first to share an update with the local farming community.</p>
            </Card>
          ) : posts.map(post => (
            <Card key={post.id} className="p-6 bg-card/40 border-white/5">
              <div className="flex items-center gap-3 mb-4">
                <img src={post.author?.avatar_url || "https://api.dicebear.com/7.x/avataaars/svg?seed=" + post.author_id} alt={post.author?.full_name} className="w-12 h-12 rounded-full bg-white/5" />
                <div>
                  <div className="flex items-center gap-2">
                    <h3 className="font-bold text-white">{post.author?.full_name || 'Anonymous Farmer'}</h3>
                    {post.is_expert && <span className="bg-blue-500/20 text-blue-400 text-[10px] uppercase font-bold px-1.5 py-0.5 rounded">Expert</span>}
                  </div>
                  <div className="text-xs text-muted-foreground">{new Date(post.created_at).toLocaleDateString()}</div>
                </div>
              </div>
              
              <p className="text-sm text-white/90 mb-4 leading-relaxed">{post.content}</p>
              
              {post.image_url && (
                <div className="rounded-xl overflow-hidden mb-4 border border-white/5">
                  <img src={post.image_url} alt="Post Attachment" className="w-full h-64 object-cover" />
                </div>
              )}
              
              <div className="flex gap-2 mb-4">
                {post.tags?.map((tag: string) => (
                  <span key={tag} className="text-xs bg-white/5 text-muted-foreground px-2 py-1 rounded-md">#{tag}</span>
                ))}
              </div>
              
              <div className="w-full h-px bg-white/5 mb-4" />
              
              <div className="flex justify-between items-center text-muted-foreground">
                <div className="flex gap-6">
                  <button className="flex items-center gap-2 text-sm hover:text-rose-400 transition-colors">
                    <Heart size={18} /> {post.likes || 0}
                  </button>
                  <button className="flex items-center gap-2 text-sm hover:text-white transition-colors">
                    <MessageSquare size={18} /> {post.comments || 0}
                  </button>
                </div>
                <button className="flex items-center gap-2 text-sm hover:text-white transition-colors">
                  <Share2 size={18} /> Share
                </button>
              </div>
            </Card>
          ))}
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          <Card className="p-6 bg-card/40 border-white/5">
            <h3 className="font-bold text-white mb-4 flex items-center gap-2"><Flame className="text-rose-500" size={18} /> Trending Topics</h3>
            <div className="space-y-4">
              <div>
                <div className="text-sm font-semibold text-primary">#MonsoonPrep</div>
                <div className="text-xs text-muted-foreground">1.2k discussions</div>
              </div>
              <div>
                <div className="text-sm font-semibold text-white">#CottonPrices</div>
                <div className="text-xs text-muted-foreground">856 discussions</div>
              </div>
              <div>
                <div className="text-sm font-semibold text-white">#DripIrrigation</div>
                <div className="text-xs text-muted-foreground">432 discussions</div>
              </div>
            </div>
          </Card>
          
          <Card className="p-6 bg-card/40 border-white/5">
            <h3 className="font-bold text-white mb-4 flex items-center gap-2"><Users className="text-blue-400" size={18} /> Nearby Experts</h3>
            <div className="space-y-4">
              <div className="flex items-center gap-3">
                <img src="https://api.dicebear.com/7.x/avataaars/svg?seed=Doc1" className="w-10 h-10 rounded-full" />
                <div>
                  <div className="text-sm font-semibold">Dr. A. Sharma</div>
                  <div className="text-xs text-muted-foreground">Soil Scientist</div>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <img src="https://api.dicebear.com/7.x/avataaars/svg?seed=Doc2" className="w-10 h-10 rounded-full" />
                <div>
                  <div className="text-sm font-semibold">V. Desai</div>
                  <div className="text-xs text-muted-foreground">Pest Control</div>
                </div>
              </div>
            </div>
            <Button variant="outline" className="w-full mt-4 text-xs h-8">View Directory</Button>
          </Card>
        </div>

      </div>
    </div>
  );
}
