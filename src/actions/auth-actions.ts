'use server';

import { createClient } from '@/lib/supabase/server';
import { redirect } from 'next/navigation';

export async function login(formData: FormData) {
  const email = formData.get('email') as string;
  const password = formData.get('password') as string;

  if (!email || !password) {
    return { error: 'Email and password are required' };
  }

  const supabase = await createClient();

  const { error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (error) {
    return { error: error.message };
  }

  return { success: true };
}

export async function register(formData: FormData) {
  const email = formData.get('email') as string;
  const password = formData.get('password') as string;
  const fullName = formData.get('name') as string;

  if (!email || !password) {
    return { error: 'Email and password are required' };
  }

  const supabase = await createClient();

  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: {
        full_name: fullName,
      },
    }
  });

  if (error) {
    return { error: error.message };
  }

  if (data.user) {
    // Automatically create profile on successful registration
    const { error: profileError } = await supabase
      .from('profiles')
      .insert({
        user_id: data.user.id,
        full_name: fullName,
        email: email,
        role: 'Farmer',
        avatar_url: null,
      });

    if (profileError) {
      console.error("Failed to create profile:", profileError);
      // We still return success for auth, but profile creation failed
    }
  }

  return { success: 'Registration successful! Please check your email to verify your account.' };
}

export async function logout() {
  const supabase = await createClient();
  await supabase.auth.signOut();
  redirect('/login');
}

export async function resetPassword(formData: FormData) {
  const email = formData.get('email') as string;
  if (!email) return { error: 'Email is required' };

  const supabase = await createClient();
  const { error } = await supabase.auth.resetPasswordForEmail(email, {
    redirectTo: `${process.env.NEXT_PUBLIC_SITE_URL || 'http://localhost:3000'}/update-password`,
  });

  if (error) return { error: error.message };
  return { success: 'Password reset link sent to your email.' };
}

export async function updatePassword(formData: FormData) {
  const password = formData.get('password') as string;
  if (!password) return { error: 'Password is required' };

  const supabase = await createClient();
  const { error } = await supabase.auth.updateUser({
    password,
  });

  if (error) return { error: error.message };
  return { success: 'Password has been updated successfully.' };
}
