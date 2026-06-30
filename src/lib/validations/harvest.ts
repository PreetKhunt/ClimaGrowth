import { z } from 'zod';

export const transportBookingSchema = z.object({
  pickup_farm_id: z.string().uuid(),
  vehicle_type: z.string().min(1, "Vehicle type is required"),
  capacity_tons: z.coerce.number().positive("Capacity must be positive"),
  destination: z.string().min(1, "Destination is required"),
  pickup_date: z.string().min(1, "Pickup date is required"),
  pickup_time: z.string().min(1, "Pickup time is required"),
  contact_number: z.string().min(10, "Valid contact number required"),
  notes: z.string().optional(),
});
