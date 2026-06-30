'use server';

import { safeAction } from '@/lib/actions/safe-action';
import { revalidatePath } from 'next/cache';
import { z } from 'zod';
import { learningProgressSchema } from '@/lib/validations/academy';

export const updateLearningProgress = async (data: z.infer<typeof learningProgressSchema>) => {
  return safeAction(
    learningProgressSchema,
    data,
    async (validatedData, { userId, supabase }) => {
      // Upsert progress
      const { data: result, error } = await supabase
        .from('learning_progress')
        .upsert(
          { 
            user_id: userId,
            course_id: validatedData.course_id,
            lesson_id: validatedData.lesson_id,
            status: validatedData.status,
            video_timestamp_seconds: validatedData.video_timestamp_seconds
          },
          { onConflict: 'user_id,course_id,lesson_id' }
        )
        .select()
        .single();
        
      if (error) throw new Error(error.message);
      
      revalidatePath('/dashboard/academy');
      return result;
    }
  );
};
