/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable react/no-unescaped-entities */
/* eslint-disable @typescript-eslint/no-unused-vars */
/* eslint-disable @typescript-eslint/no-require-imports */
import { z } from 'zod';
import { createClient } from '@/lib/supabase/server';
import { AppError, ServerError, UnauthorizedError, ValidationError } from '../utils/errors';
import { logAuditAction, AuditAction } from '../services/audit';

export type ActionState<T = any> = {
  success: boolean;
  data?: T;
  error?: string;
};

/**
 * Enterprise Server Action Wrapper
 * Standardizes Auth, Zod Validation, Error Handling, and Audit Logging.
 */
export async function safeAction<TSchema extends z.ZodType, TResult>(
  schema: TSchema,
  input: unknown,
  handler: (
    validatedData: z.infer<TSchema>,
    ctx: { userId: string; supabase: any }
  ) => Promise<TResult>,
  options?: {
    requireAuth?: boolean;
    auditLog?: {
      action: AuditAction;
      entityType: string;
      getEntityId?: (res: TResult) => string;
    }
  }
): Promise<ActionState<TResult>> {
  try {
    // 1. Validation
    const validationResult = schema.safeParse(input);
    if (!validationResult.success) {
      throw new ValidationError(validationResult.error.issues[0].message);
    }

    const supabase = await createClient();
    let userId = '';

    // 2. Authentication Check
    if (options?.requireAuth !== false) {
      const { data: { user }, error: authError } = await supabase.auth.getUser();
      if (authError || !user) {
        throw new UnauthorizedError();
      }
      userId = user.id;
    }

    // 3. Execution
    const result = await handler(validationResult.data, { userId, supabase });

    // 4. Audit Logging
    if (options?.auditLog && userId) {
      const entityId = options.auditLog.getEntityId ? options.auditLog.getEntityId(result) : 'N/A';
      await logAuditAction({
        userId,
        action: options.auditLog.action,
        entityType: options.auditLog.entityType,
        entityId,
        metadata: { input: validationResult.data }
      });
    }

    return { success: true, data: result };

  } catch (error: any) {
    console.error('[SafeAction Error]', error);
    if (error instanceof AppError) {
      return { success: false, error: error.message };
    }
    if (error instanceof Error) {
      return { success: false, error: error.message };
    }
    return { success: false, error: 'An unexpected error occurred.' };
  }
}
