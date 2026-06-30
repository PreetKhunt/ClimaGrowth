'use server';

import { safeAction } from '@/lib/actions/safe-action';
import { revalidatePath } from 'next/cache';
import { profileSchema } from '@/lib/validations/profile';
import { z } from 'zod';

export const updateProfile = async (data: z.infer<typeof profileSchema>) => {
  return safeAction(
    profileSchema,
    data,
    async (validatedData, { userId, supabase }) => {
      const { data: profile, error } = await supabase
        .from('profiles')
        .update({
          full_name: validatedData.full_name,
          phone: validatedData.phone,
          avatar_url: validatedData.avatar_url,
          updated_at: new Date().toISOString()
        })
        .eq('id', userId)
        .select()
        .single();

      if (error) throw new Error(error.message);

      revalidatePath('/dashboard/profile');
      return profile;
    },
    {
      auditLog: {
        action: 'UPDATE_PROFILE',
        entityType: 'profile',
        getEntityId: (profile) => profile.id
      }
    }
  );
};

export const fetchProfile = async () => {
  return safeAction(
    z.any(),
    null,
    async (_, { userId, supabase }) => {
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .single();

      // If PGRST116 (0 rows returned), profile doesn't exist yet, we can create one
      if (error && error.code === 'PGRST116') {
        const { data: newProfile, error: insertError } = await supabase
          .from('profiles')
          .insert({ id: userId })
          .select()
          .single();
          
        if (insertError) throw new Error(insertError.message);
        return newProfile;
      }
      
      if (error) throw new Error(error.message);
      return data;
    }
  );
};
