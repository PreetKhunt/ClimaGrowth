import { z } from 'zod';

export const profileSchema = z.object({
  full_name: z.string().min(2, "Name must be at least 2 characters").optional(),
  phone: z.string().optional(),
  avatar_url: z.string().url().optional().or(z.literal('')),
});

export type ProfileInput = z.infer<typeof profileSchema>;
