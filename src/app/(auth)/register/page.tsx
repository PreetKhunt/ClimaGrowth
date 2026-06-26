"use client";

import { useState } from 'react';
import { useTranslations } from 'next-intl';
import { useRouter } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';
import { Loader2 } from 'lucide-react';
import { toast } from 'sonner';

export default function RegisterPage() {
  const t = useTranslations('Auth');
  const router = useRouter();
  const supabase = createClient();
  
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    
    // 1. Sign up the user
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          full_name: name,
        },
        emailRedirectTo: `${location.origin}/api/auth/callback`,
      }
    });

    if (error) {
      toast.error(error.message);
      setLoading(false);
      return;
    }

    toast.success('Registration successful! Please check your email to verify your account.');
    router.push('/login');
  };

  return (
    <div className="flex h-screen items-center justify-center p-4 relative">
      <div className="absolute inset-0 bg-[url('https://images.unsplash.com/photo-1595804369792-74d306b3fa1d?w=1600&q=80')] bg-cover bg-center opacity-20" />
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" />
      
      <div className="max-w-md w-full bg-black/40 backdrop-blur-xl border border-white/10 rounded-2xl p-8 shadow-2xl relative z-10">
        <div className="flex justify-center mb-6">
          <div className="text-3xl font-bold tracking-tight text-white">Clima<span className="text-primary">Growth</span></div>
        </div>
        
        <h1 className="text-xl font-semibold mb-2 text-center text-white">{t('register')}</h1>
        <p className="text-muted-foreground text-sm mb-8 text-center">Join thousands of smart farmers today.</p>
        
        <form className="space-y-5" onSubmit={handleRegister}>
          <div>
            <label className="block text-sm font-medium mb-1.5 text-white/80">Full Name</label>
            <input 
              type="text" 
              required 
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="w-full border border-white/10 rounded-lg px-4 py-3 text-sm bg-white/5 focus:outline-none focus:ring-2 focus:ring-primary text-white" 
              placeholder="e.g. Ramesh Patel"
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1.5 text-white/80">{t('email')}</label>
            <input 
              type="email" 
              required 
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full border border-white/10 rounded-lg px-4 py-3 text-sm bg-white/5 focus:outline-none focus:ring-2 focus:ring-primary text-white" 
              placeholder="Enter your email"
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1.5 text-white/80">{t('password')}</label>
            <input 
              type="password" 
              required 
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full border border-white/10 rounded-lg px-4 py-3 text-sm bg-white/5 focus:outline-none focus:ring-2 focus:ring-primary text-white" 
              placeholder="Create a secure password"
              minLength={6}
            />
          </div>
          
          <button 
            type="submit" 
            disabled={loading}
            className="w-full bg-primary hover:bg-primary/90 text-primary-foreground py-3 rounded-lg font-bold transition-all disabled:opacity-50 disabled:cursor-not-allowed flex justify-center items-center gap-2 mt-4"
          >
            {loading && <Loader2 className="animate-spin w-4 h-4" />}
            {loading ? 'Creating account...' : t('submit')}
          </button>
        </form>
        
        <div className="mt-6 text-center text-sm text-muted-foreground">
          Already have an account? <a href="/login" className="text-primary hover:underline font-semibold">Sign in</a>
        </div>
      </div>
    </div>
  );
}
