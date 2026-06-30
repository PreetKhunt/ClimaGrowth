import { z } from 'zod';

export const learningProgressSchema = z.object({
  course_id: z.string().min(1),
  lesson_id: z.string().min(1),
  status: z.enum(['in_progress', 'completed']),
  video_timestamp_seconds: z.number().min(0).default(0),
});
