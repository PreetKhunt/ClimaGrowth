/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable react/no-unescaped-entities */
/* eslint-disable @typescript-eslint/no-unused-vars */
/* eslint-disable @typescript-eslint/no-require-imports */
"use client";

import { useEffect, useState, useRef } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { Loader2, Upload, User, Camera } from "lucide-react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { profileSchema, type ProfileInput } from "@/lib/validations/profile";
import { fetchProfile, updateProfile } from "@/actions/profile-actions";
import { createClient } from "@/lib/supabase/client";

export default function ProfilePage() {
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [profile, setProfile] = useState<any>(null);
  const [avatarUploading, setAvatarUploading] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const supabase = createClient();

  const form = useForm<ProfileInput>({
    resolver: zodResolver(profileSchema),
    defaultValues: {
      full_name: "",
      phone: "",
      avatar_url: ""
    }
  });

  useEffect(() => {
    async function loadData() {
      const res = await fetchProfile();
      if (res.success && res.data) {
        setProfile(res.data);
        form.reset({
          full_name: res.data.full_name || "",
          phone: res.data.phone || "",
          avatar_url: res.data.avatar_url || ""
        });
      }
      setLoading(false);
    }
    loadData();
  }, [form]);

  const onSubmit = async (data: ProfileInput) => {
    setSaving(true);
    try {
      const res = await updateProfile(data);
      if (!res.success) throw new Error(res.error);
      setProfile(res.data);
      alert("Profile updated successfully!");
    } catch (err: any) {
      alert(err.message || "Failed to update profile");
    } finally {
      setSaving(false);
    }
  };

  const handleAvatarUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    if (!e.target.files || e.target.files.length === 0) return;
    
    const file = e.target.files[0];
    setAvatarUploading(true);
    
    try {
      // 1. Get user id for bucket path
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error("Not authenticated");
      
      const fileExt = file.name.split('.').pop();
      const filePath = `${user.id}-${Math.random()}.${fileExt}`;
      
      // 2. Upload to storage
      const { error: uploadError } = await supabase.storage
        .from('avatars')
        .upload(filePath, file);
        
      if (uploadError) throw new Error(uploadError.message);
      
      // 3. Get public URL
      const { data: { publicUrl } } = supabase.storage
        .from('avatars')
        .getPublicUrl(filePath);
        
      // 4. Update form
      form.setValue('avatar_url', publicUrl, { shouldDirty: true });
      
      // 5. Optionally save immediately
      const currentValues = form.getValues();
      await updateProfile(currentValues);
      setProfile({ ...profile, avatar_url: publicUrl });
      
    } catch (err: any) {
      alert("Failed to upload avatar: " + err.message);
    } finally {
      setAvatarUploading(false);
      if (fileInputRef.current) {
        fileInputRef.current.value = "";
      }
    }
  };

  if (loading) {
    return <div className="p-8 flex justify-center"><Loader2 className="animate-spin text-primary" /></div>;
  }

  const avatarUrl = form.watch("avatar_url");

  return (
    <div className="p-8 max-w-4xl mx-auto space-y-8">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Profile</h1>
        <p className="text-muted-foreground mt-1">Manage your personal information and farm details.</p>
      </div>

      <div className="grid gap-8">
        <Card className="bg-card/40 border border-white/5 p-6">
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
            <div className="flex items-center gap-6">
              <div className="relative group">
                {avatarUrl ? (
                  <img src={avatarUrl} alt="Avatar" className="w-24 h-24 rounded-full object-cover border-2 border-white/10" />
                ) : (
                  <div className="w-24 h-24 rounded-full bg-primary/20 flex items-center justify-center text-primary text-3xl font-bold border-2 border-primary/20">
                    <User size={40} />
                  </div>
                )}
                
                <input 
                  type="file" 
                  accept="image/*" 
                  className="hidden" 
                  ref={fileInputRef} 
                  onChange={handleAvatarUpload} 
                />
                
                <button 
                  type="button"
                  onClick={() => fileInputRef.current?.click()}
                  disabled={avatarUploading}
                  className="absolute inset-0 flex items-center justify-center bg-black/60 rounded-full opacity-0 group-hover:opacity-100 transition-opacity cursor-pointer"
                >
                  {avatarUploading ? <Loader2 className="animate-spin text-white" size={24} /> : <Camera className="text-white" size={24} />}
                </button>
              </div>
              
              <div>
                <h2 className="text-2xl font-semibold">{profile?.full_name || 'Anonymous Farmer'}</h2>
                <p className="text-muted-foreground mb-3">Update your photo and personal details.</p>
                <Button type="button" variant="outline" size="sm" onClick={() => fileInputRef.current?.click()} disabled={avatarUploading}>
                  {avatarUploading ? "Uploading..." : "Change Avatar"}
                </Button>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6 pt-4 border-t border-white/5">
              <div className="space-y-2">
                <label className="text-sm font-medium">Full Name</label>
                <Input 
                  {...form.register("full_name")}
                  className="bg-background/50 border-white/10"
                  placeholder="e.g. Preet Khunt"
                />
                {form.formState.errors.full_name && (
                  <p className="text-sm text-red-400">{form.formState.errors.full_name.message}</p>
                )}
              </div>
              
              <div className="space-y-2">
                <label className="text-sm font-medium">Phone Number</label>
                <Input 
                  {...form.register("phone")}
                  className="bg-background/50 border-white/10"
                  placeholder="e.g. +91 98765 43210"
                />
                {form.formState.errors.phone && (
                  <p className="text-sm text-red-400">{form.formState.errors.phone.message}</p>
                )}
              </div>
            </div>

            <div className="flex justify-end pt-4">
              <Button type="submit" disabled={saving || !form.formState.isDirty} className="bg-primary text-primary-foreground min-w-[120px]">
                {saving ? <Loader2 className="animate-spin w-4 h-4 mr-2" /> : null}
                {saving ? "Saving..." : "Save Changes"}
              </Button>
            </div>
          </form>
        </Card>
      </div>
    </div>
  );
}
