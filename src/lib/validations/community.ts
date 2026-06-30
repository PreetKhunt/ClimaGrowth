import { z } from 'zod';

export const postSchema = z.object({
  content: z.string().optional(),
  image: z.any().optional(), // File is handled via FormData
}).refine(data => data.content || data.image, {
  message: "Post must contain either text or an image",
  path: ["content"],
});
