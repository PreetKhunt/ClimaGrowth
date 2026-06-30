import { z } from 'zod';

export const farmSchema = z.object({
  name: z.string().min(2, "Farm name must be at least 2 characters"),
  area_acres: z.coerce.number().positive("Area must be positive"),
  soil_type: z.string().min(1, "Soil type is required"),
  crop_type: z.string().min(1, "Crop type is required"),
  irrigation_type: z.string().min(1, "Irrigation type is required"),
  water_source: z.string().min(1, "Water source is required"),
  coordinates: z.any().optional(), // Could be strictly typed as LatLng tuple
  images: z.array(z.string()).optional()
});

export type FarmInput = z.infer<typeof farmSchema>;

export const diseaseScanSchema = z.object({
  farm_id: z.string().uuid().optional(),
  image_url: z.string().url("Must be a valid image URL"),
  disease_name: z.string(),
  confidence_score: z.number().min(0).max(1),
  symptoms: z.any().optional(),
  cause: z.string().optional(),
  treatment: z.any().optional(),
  recommended_fertilizers: z.any().optional(),
  recommended_pesticides: z.any().optional(),
  prevention_tips: z.any().optional()
});

export type DiseaseScanInput = z.infer<typeof diseaseScanSchema>;
