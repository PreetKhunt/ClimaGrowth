/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable react/no-unescaped-entities */
/* eslint-disable @typescript-eslint/no-require-imports */
"use client";

import { useState } from 'react';
import { useTranslations } from 'next-intl';
import { Loader2 } from 'lucide-react';
import { toast } from 'sonner';
import { login } from '@/actions/auth-actions';

export default function LoginPage() {
  const t = useTranslations('Auth');
  
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);

  const handleLogin = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setLoading(true);
    
    try {
      const formData = new FormData(e.currentTarget);
      const result = await login(formData);

      if (result?.error) {
        toast.error(result.error);
      } else {
        // Redirection happens in the server action, but just in case:
        toast.success('Successfully logged in');
      }
    } catch (err: any) {
      console.error("Login exception:", err);
      toast.error(err?.message || "An unexpected error occurred");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex h-screen items-center justify-center p-4 relative">
      <div className="absolute inset-0 bg-[url('https://images.unsplash.com/photo-1592982537447-6f296d9b2447?w=1600&q=80')] bg-cover bg-center opacity-20" />
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" />
      
      <div className="max-w-md w-full bg-black/40 backdrop-blur-xl border border-white/10 rounded-2xl p-8 shadow-2xl relative z-10">
        <div className="flex justify-center mb-6">
          <div className="text-3xl font-bold tracking-tight text-white">Clima<span className="text-primary">Growth</span></div>
        </div>
        
        <h1 className="text-xl font-semibold mb-2 text-center text-white">{t('login')}</h1>
        <p className="text-muted-foreground text-sm mb-8 text-center">Welcome back! Please enter your details.</p>
        
        <form className="space-y-5" onSubmit={handleLogin}>
          <div>
            <label className="block text-sm font-medium mb-1.5 text-white/80">{t('email')}</label>
            <input 
              name="email"
              type="email" 
              required 
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full border border-white/10 rounded-lg px-4 py-3 text-sm bg-white/5 focus:outline-none focus:ring-2 focus:ring-primary text-white" 
              placeholder="Enter your email"
            />
          </div>
          <div>
            <div className="flex justify-between items-center mb-1.5">
              <label className="block text-sm font-medium text-white/80">{t('password')}</label>
              <a href="/forgot-password" className="text-xs text-primary hover:underline">Forgot Password?</a>
            </div>
            <input 
              name="password"
              type="password" 
              required 
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full border border-white/10 rounded-lg px-4 py-3 text-sm bg-white/5 focus:outline-none focus:ring-2 focus:ring-primary text-white" 
              placeholder="••••••••"
            />
          </div>
          
          <button 
            type="submit" 
            disabled={loading}
            className="w-full bg-primary hover:bg-primary/90 text-primary-foreground py-3 rounded-lg font-bold transition-all disabled:opacity-50 disabled:cursor-not-allowed flex justify-center items-center gap-2 mt-4"
          >
            {loading && <Loader2 className="animate-spin w-4 h-4" />}
            {loading ? 'Signing in...' : t('submit')}
          </button>
        </form>
        
        <div className="mt-6 text-center text-sm text-muted-foreground">
          Don't have an account? <a href="/register" className="text-primary hover:underline font-semibold">Sign up</a>
        </div>
      </div>
    </div>
  );
}
