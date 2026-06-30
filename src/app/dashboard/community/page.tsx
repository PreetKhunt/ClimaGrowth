"use client";

import { useState, useEffect, useRef } from "react";
import { MessageSquare, Heart, Share2, Users, Flame, Plus, Loader2, Image as ImageIcon, X } from "lucide-react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { createClient } from "@/lib/supabase/client";
import { createPost, likePost, deletePost, fetchPosts } from "@/actions/community-actions";

export default function CommunityPage() {
  const supabase = createClient();
  const [posts, setPosts] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  const [content, setContent] = useState("");
  const [image, setImage] = useState<File | null>(null);
  const [imagePreview, setImagePreview] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  
  const fileInputRef = useRef<HTMLInputElement>(null);

  const loadPosts = async () => {
    setLoading(true);
    const res = await fetchPosts();
    if (res.success && res.data) {
      setPosts(res.data);
    }
    setLoading(false);
  };

  useEffect(() => {
    loadPosts();
  }, []);

  const handleImageSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      const file = e.target.files[0];
      setImage(file);
      const reader = new FileReader();
      reader.onloadend = () => {
        setImagePreview(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const removeImage = () => {
    setImage(null);
    setImagePreview(null);
    if (fileInputRef.current) {
      fileInputRef.current.value = "";
    }
  };

  const handleSubmit = async () => {
    if (!content.trim() && !image) return;
    
    setIsSubmitting(true);
    try {
      const formData = new FormData();
      formData.append('content', content);
      if (image) {
        formData.append('image', image);
      }
      
      const res = await createPost(formData);
      if (!res.success) throw new Error(res.error);
      
      setContent("");
      removeImage();
      await loadPosts();
    } catch (err: any) {
      alert(err.message || 'Failed to create post');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleLike = async (postId: string) => {
    try {
      // Optimistic update
      setPosts(posts.map(p => p.id === postId ? { ...p, likes_count: (p.likes_count || 0) + 1 } : p));
      await likePost(postId);
    } catch (err) {
      console.error(err);
      await loadPosts(); // revert on fail
    }
  };

  const handleDelete = async (postId: string) => {
    if (!confirm('Are you sure you want to delete this post?')) return;
    try {
      await deletePost(postId);
      await loadPosts();
    } catch (err: any) {
      alert(err.message || 'Failed to delete post');
    }
  };

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
            <img src="https://api.dicebear.com/7.x/avataaars/svg?seed=Me" alt="You" className="w-10 h-10 rounded-full bg-white/5 shrink-0" />
            <div className="flex-1">
              <textarea 
                placeholder="Share an update or ask a question..." 
                className="w-full bg-transparent border-none focus:outline-none text-white text-sm mt-2 resize-none min-h-[40px]"
                value={content}
                onChange={(e) => setContent(e.target.value)}
              />
              
              {imagePreview && (
                <div className="relative mt-2 mb-2 w-32 h-32 rounded-md overflow-hidden border border-white/10">
                  <img src={imagePreview} alt="Preview" className="w-full h-full object-cover" />
                  <button onClick={removeImage} className="absolute top-1 right-1 bg-black/50 rounded-full p-1 hover:bg-black text-white">
                    <X size={14} />
                  </button>
                </div>
              )}

              <div className="w-full h-px bg-white/10 my-3" />
              <div className="flex justify-between items-center">
                <div className="flex gap-2">
                  <input type="file" accept="image/*" className="hidden" ref={fileInputRef} onChange={handleImageSelect} />
                  <Button variant="ghost" size="sm" className="text-muted-foreground hover:text-white h-8 px-2 text-xs" onClick={() => fileInputRef.current?.click()}>
                    <ImageIcon size={14} className="mr-1" /> Photo
                  </Button>
                </div>
                <Button 
                  size="sm" 
                  className="h-8 bg-primary text-primary-foreground" 
                  onClick={handleSubmit}
                  disabled={isSubmitting || (!content.trim() && !image)}
                >
                  {isSubmitting ? <Loader2 className="animate-spin w-4 h-4 mr-2" /> : null}
                  Post
                </Button>
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
              
              <p className="text-sm text-white/90 mb-4 leading-relaxed whitespace-pre-wrap">{post.content}</p>
              
              {post.images && post.images.length > 0 && (
                <div className="rounded-xl overflow-hidden mb-4 border border-white/5">
                  <img src={post.images[0]} alt="Post Attachment" className="w-full h-64 object-cover" />
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
                  <button onClick={() => handleLike(post.id)} className="flex items-center gap-2 text-sm hover:text-rose-400 transition-colors">
                    <Heart size={18} /> {post.likes_count || 0}
                  </button>
                  <button className="flex items-center gap-2 text-sm hover:text-white transition-colors">
                    <MessageSquare size={18} /> {post.comments_count || 0}
                  </button>
                </div>
                <div className="flex gap-4">
                  <button onClick={() => handleDelete(post.id)} className="flex items-center gap-2 text-sm text-red-400/70 hover:text-red-400 transition-colors">
                    <X size={16} /> Delete
                  </button>
                  <button className="flex items-center gap-2 text-sm hover:text-white transition-colors">
                    <Share2 size={18} /> Share
                  </button>
                </div>
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
