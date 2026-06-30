'use server';

import { revalidatePath } from 'next/cache';
import { safeAction } from '@/lib/actions/safe-action';
import { inventorySchema } from '@/lib/validations/inventory';
import { z } from 'zod';

export const createInventory = async (data: z.infer<typeof inventorySchema>) => {
  return safeAction(
    inventorySchema,
    data,
    async (validatedData, { userId, supabase }) => {
      const { data: inventory, error } = await supabase
        .from('harvest_inventory')
        .insert({
          user_id: userId,
          farm_id: validatedData.farm_id || null,
          name: validatedData.name,
          category: validatedData.category,
          quantity: validatedData.quantity,
          unit: validatedData.unit,
          warehouse: validatedData.warehouse || null,
          expiry_date: validatedData.expiry_date || null,
          low_stock_threshold: validatedData.low_stock_threshold || null,
        })
        .select()
        .single();

      if (error) throw new Error(error.message);

      revalidatePath('/dashboard/harvest');
      return inventory;
    },
    {
      auditLog: {
        action: 'CREATE_INVENTORY',
        entityType: 'harvest_inventory',
        getEntityId: (inventory: any) => inventory.id
      }
    }
  );
};

export const deleteInventory = async (id: string) => {
  return safeAction(
    z.string().uuid(),
    id,
    async (inventoryId, { userId, supabase }) => {
      const { error } = await supabase
        .from('harvest_inventory')
        .delete()
        .eq('id', inventoryId)
        .eq('user_id', userId);

      if (error) throw new Error(error.message);

      revalidatePath('/dashboard/harvest');
      return { success: true };
    },
    {
      auditLog: {
        action: 'DELETE_INVENTORY',
        entityType: 'harvest_inventory',
        getEntityId: () => id
      }
    }
  );
};

export const fetchInventory = async () => {
  return safeAction(
    z.any(),
    null,
    async (_, { userId, supabase }) => {
      const { data, error } = await supabase
        .from('harvest_inventory')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false });

      if (error) throw new Error(error.message);
      return data;
    }
  );
};
