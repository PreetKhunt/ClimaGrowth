import { z } from 'zod';

export const inventorySchema = z.object({
  farm_id: z.string().uuid().optional().nullable(),
  name: z.string().min(2, 'Name must be at least 2 characters'),
  category: z.string().min(2, 'Category is required'),
  quantity: z.coerce.number().min(0, 'Quantity cannot be negative'),
  unit: z.string().min(1, 'Unit is required'),
  warehouse: z.string().optional().nullable(),
  expiry_date: z.string().optional().nullable(),
  low_stock_threshold: z.coerce.number().optional().nullable(),
});

export type InventoryInput = z.infer<typeof inventorySchema>;
