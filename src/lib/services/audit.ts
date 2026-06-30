/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable react/no-unescaped-entities */
/* eslint-disable @typescript-eslint/no-unused-vars */
/* eslint-disable @typescript-eslint/no-require-imports */
import { createClient } from '@/lib/supabase/server'; // Assume standard Next.js app directory setup
import { ServerError } from '../utils/errors';

export type AuditAction = 
  | 'CREATE_FARM' 
  | 'UPDATE_FARM'
  | 'DELETE_FARM'
  | 'UPDATE_PROFILE'
  | 'PLACE_ORDER'
  | 'CANCEL_ORDER'
  | 'BOOK_TRANSPORT'
  | 'CREATE_POST'
  | 'DELETE_POST'
  | 'GENERATE_TAX_REPORT'
  | 'CREATE_INVENTORY'
  | 'DELETE_INVENTORY';

interface AuditPayload {
  userId: string;
  action: AuditAction;
  entityType: string;
  entityId: string;
  metadata?: Record<string, any>;
}

/**
 * Enterprise Audit Logging Service
 * Records critical user actions into the audit_logs table.
 */
export async function logAuditAction(payload: AuditPayload) {
  try {
    const supabase = await createClient();
    
    // Using a background-safe approach (fire and forget) if we don't want to block the main request,
    // but for true audit we await it.
    const { error } = await supabase.from('audit_logs').insert({
      user_id: payload.userId,
      action: payload.action,
      entity_type: payload.entityType,
      entity_id: payload.entityId,
      metadata: payload.metadata || {},
      // IP and UserAgent would typically be injected by middleware or passing headers
    });

    if (error) {
      console.error('[Audit Logger] Failed to log action:', error);
      // Depending on strictness, we might throw or just log.
      // throw new ServerError('Audit logging failed');
    }
  } catch (error) {
    console.error('[Audit Logger] Exception:', error);
  }
}
