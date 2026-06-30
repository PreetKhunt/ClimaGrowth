/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable react/no-unescaped-entities */
/* eslint-disable @typescript-eslint/no-unused-vars */
/* eslint-disable @typescript-eslint/no-require-imports */
export interface BaseEntity {
  id: string;
  created_at: string;
  updated_at: string;
}

export interface Profile extends BaseEntity {
  user_id: string; // Supabase Auth UID
  full_name: string | null;
  avatar_url: string | null;
  role: string; // From UserRole
  phone_number: string | null;
  location: string | null;
  preferences: Record<string, any>;
}

export interface AuditLog extends BaseEntity {
  user_id: string;
  action: string;
  entity_type: string;
  entity_id: string;
  metadata: Record<string, any>;
  ip_address: string | null;
  user_agent: string | null;
}
