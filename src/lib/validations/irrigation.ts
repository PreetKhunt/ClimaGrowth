import { z } from 'zod';

export const irrigationConfigSchema = z.object({
  farm_id: z.string().uuid(),
  moisture_threshold: z.coerce.number().min(0).max(100),
  temperature_threshold: z.coerce.number().min(0).max(60).optional(),
  rain_detection_enabled: z.boolean().default(true),
  emergency_watering_enabled: z.boolean().default(false),
  watering_schedule: z.any().optional()
});

export const togglePumpSchema = z.object({
  farmId: z.string().uuid(),
  status: z.boolean()
});
