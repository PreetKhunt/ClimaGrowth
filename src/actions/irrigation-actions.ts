'use server';

import { safeAction } from '@/lib/actions/safe-action';
import { revalidatePath } from 'next/cache';
import { z } from 'zod';

import { irrigationConfigSchema, togglePumpSchema } from '@/lib/validations/irrigation';

export const upsertIrrigationConfig = async (data: z.infer<typeof irrigationConfigSchema>) => {
  return safeAction(
    irrigationConfigSchema,
    data,
    async (validatedData, { userId, supabase }) => {
      // Check if config exists
      const { data: existing } = await supabase
        .from('irrigation_configs')
        .select('id')
        .eq('farm_id', validatedData.farm_id)
        .eq('user_id', userId)
        .single();

      let result;
      
      if (existing) {
        // Update
        const { data: updated, error } = await supabase
          .from('irrigation_configs')
          .update(validatedData)
          .eq('id', existing.id)
          .select()
          .single();
        if (error) throw new Error(error.message);
        result = updated;
      } else {
        // Insert
        const { data: inserted, error } = await supabase
          .from('irrigation_configs')
          .insert({
            ...validatedData,
            user_id: userId
          })
          .select()
          .single();
        if (error) throw new Error(error.message);
        result = inserted;
      }

      revalidatePath('/dashboard/irrigation');
      return result;
    },
    {
      auditLog: {
        action: 'UPDATE_FARM',
        entityType: 'irrigation_config',
        getEntityId: (c) => c.id
      }
    }
  );
};

export const fetchIrrigationConfig = async (farmId: string) => {
  return safeAction(
    z.string().uuid(),
    farmId,
    async (fid, { userId, supabase }) => {
      const { data, error } = await supabase
        .from('irrigation_configs')
        .select('*')
        .eq('farm_id', fid)
        .eq('user_id', userId)
        .single();
        
      if (error && error.code !== 'PGRST116') throw new Error(error.message);
      return data || null;
    }
  );
};

export const togglePumpStatus = async (farmId: string, status: boolean) => {
  return safeAction(
    togglePumpSchema,
    { farmId, status },
    async (input, { userId, supabase }) => {
      const newStatus = input.status ? 'on' : 'off';
      
      const { data: existing } = await supabase
        .from('irrigation_configs')
        .select('id')
        .eq('farm_id', input.farmId)
        .single();

      if (!existing) {
        // Create basic config if none exists to hold the pump state
        const { error } = await supabase
          .from('irrigation_configs')
          .insert({
            user_id: userId,
            farm_id: input.farmId,
            moisture_threshold: 40,
            pump_status: newStatus
          });
        if (error) throw new Error(error.message);
      } else {
        const { error } = await supabase
          .from('irrigation_configs')
          .update({ pump_status: newStatus })
          .eq('id', existing.id);
        if (error) throw new Error(error.message);
      }

      revalidatePath('/dashboard/irrigation');
      return { pump_status: newStatus };
    },
    {
      auditLog: {
        action: 'UPDATE_FARM',
        entityType: 'irrigation_pump',
        getEntityId: () => farmId
      }
    }
  );
};
