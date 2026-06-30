'use server';

import { revalidatePath } from 'next/cache';
import { safeAction } from '@/lib/actions/safe-action';
import { farmSchema } from '@/lib/validations/farm';
import { z } from 'zod';

export const createFarm = async (data: z.infer<typeof farmSchema>) => {
  return safeAction(
    farmSchema,
    data,
    async (validatedData, { userId, supabase }) => {
      const { data: farm, error } = await supabase
        .from('farms')
        .insert({
          name: validatedData.name,
          area_acres: validatedData.area_acres,
          soil_type: validatedData.soil_type,
          crop_type: validatedData.crop_type,
          irrigation_type: validatedData.irrigation_type,
          water_source: validatedData.water_source,
          images: validatedData.images || [],
          coordinates: validatedData.coordinates || null,
          user_id: userId
        })
        .select()
        .single();

      if (error) throw new Error(error.message);

      revalidatePath('/dashboard/farms');
      return farm;
    },
    {
      auditLog: {
        action: 'CREATE_FARM',
        entityType: 'farm',
        getEntityId: (farm) => farm.id
      }
    }
  );
};

export const deleteFarm = async (farmId: string) => {
  return safeAction(
    z.string().uuid(),
    farmId,
    async (id, { userId, supabase }) => {
      const { error } = await supabase
        .from('farms')
        .delete()
        .eq('id', id)
        .eq('user_id', userId); // Ensure ownership

      if (error) throw new Error(error.message);

      revalidatePath('/dashboard/farms');
      return { success: true };
    },
    {
      auditLog: {
        action: 'DELETE_FARM',
        entityType: 'farm',
        getEntityId: () => farmId
      }
    }
  );
};

export const fetchFarms = async () => {
  // Safe action wrapper can be used for reads as well to ensure auth and error handling
  return safeAction(
    z.any(),
    null,
    async (_, { userId, supabase }) => {
      const { data, error } = await supabase
        .from('farms')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false });

      if (error) throw new Error(error.message);
      return data;
    }
  );
};
