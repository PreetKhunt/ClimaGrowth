import { createClient } from '@/lib/supabase/client';
import { ServerError, ValidationError } from '../utils/errors';

export type StorageBucket = 
  | 'disease-images'
  | 'farm-images'
  | 'community-images'
  | 'avatars'
  | 'product-images';

interface UploadOptions {
  bucket: StorageBucket;
  file: File;
  path?: string; // Optional custom path, otherwise random UUID is used
  maxSizeMB?: number;
  allowedTypes?: string[];
}

/**
 * Enterprise Storage Service
 * Handles unified file validation, uploading, and error management via Supabase.
 */
export class StorageService {
  /**
   * Uploads a file to a specified Supabase storage bucket after validating size and type.
   */
  static async uploadFile({
    bucket,
    file,
    path,
    maxSizeMB = 5,
    allowedTypes = ['image/jpeg', 'image/png', 'image/webp']
  }: UploadOptions): Promise<string> {
    
    // 1. Validate File Size
    const maxSizeBytes = maxSizeMB * 1024 * 1024;
    if (file.size > maxSizeBytes) {
      throw new ValidationError(`File exceeds maximum size of ${maxSizeMB}MB`);
    }

    // 2. Validate File Type
    if (!allowedTypes.includes(file.type)) {
      throw new ValidationError(`Invalid file type. Allowed: ${allowedTypes.join(', ')}`);
    }

    const supabase = createClient();
    
    // 3. Generate Path
    const fileExtension = file.name.split('.').pop();
    const fileName = path || `${crypto.randomUUID()}.${fileExtension}`;

    // 4. Upload to Supabase Storage
    const { data, error } = await supabase
      .storage
      .from(bucket)
      .upload(fileName, file, {
        cacheControl: '3600',
        upsert: false
      });

    if (error) {
      console.error(`[StorageService] Upload failed for bucket ${bucket}:`, error);
      throw new ServerError('Failed to upload file to storage');
    }

    // 5. Return Public URL
    const { data: publicUrlData } = supabase
      .storage
      .from(bucket)
      .getPublicUrl(data.path);

    return publicUrlData.publicUrl;
  }

  /**
   * Deletes a file from storage given its path.
   */
  static async deleteFile(bucket: StorageBucket, path: string): Promise<void> {
    const supabase = createClient();
    const { error } = await supabase.storage.from(bucket).remove([path]);
    
    if (error) {
      console.error(`[StorageService] Delete failed for ${path} in ${bucket}:`, error);
      throw new ServerError('Failed to delete file from storage');
    }
  }
}
