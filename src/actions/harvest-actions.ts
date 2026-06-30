'use server';

import { safeAction } from '@/lib/actions/safe-action';
import { revalidatePath } from 'next/cache';
import { z } from 'zod';

import { transportBookingSchema } from '@/lib/validations/harvest';

export const createTransportBooking = async (data: z.infer<typeof transportBookingSchema>) => {
  return safeAction(
    transportBookingSchema,
    data,
    async (validatedData, { userId, supabase }) => {
      const { data: booking, error } = await supabase
        .from('transport_bookings')
        .insert({
          ...validatedData,
          user_id: userId,
          status: 'pending'
        })
        .select()
        .single();

      if (error) throw new Error(error.message);

      revalidatePath('/dashboard/harvest');
      return booking;
    },
    {
      auditLog: {
        action: 'CREATE_FARM', // Using an existing enum
        entityType: 'transport_booking',
        getEntityId: (b) => b.id
      }
    }
  );
};

export const fetchTransportBookings = async () => {
  return safeAction(
    z.any(),
    null,
    async (_, { userId, supabase }) => {
      const { data, error } = await supabase
        .from('transport_bookings')
        .select(`
          *,
          farms ( name )
        `)
        .eq('user_id', userId)
        .order('created_at', { ascending: false });
        
      if (error) throw new Error(error.message);
      return data;
    }
  );
};
