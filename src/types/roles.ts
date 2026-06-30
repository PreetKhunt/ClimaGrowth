/**
 * Defines the strict Role-Based Access Control (RBAC) enumerations for ClimaGrowth.
 */

export const USER_ROLES = {
  FARMER: "farmer",
  BUYER: "buyer",
  TRANSPORT_PROVIDER: "transport_provider",
  AGRONOMIST: "agronomist",
  ADMIN: "admin",
  SUPER_ADMIN: "super_admin",
} as const;

export type UserRole = (typeof USER_ROLES)[keyof typeof USER_ROLES];

export const ROLE_PERMISSIONS = {
  [USER_ROLES.FARMER]: [
    "create:farm", "read:farm", "update:farm", "delete:farm",
    "create:disease_scan", "read:disease_scan", "delete:disease_scan",
    "create:yield_prediction", "read:yield_prediction",
    "create:irrigation_config", "read:irrigation_config", "update:irrigation_config",
    "create:transport_booking", "read:transport_booking",
    "create:post", "read:post", "delete:post", "update:post",
    "create:comment", "create:like",
  ],
  [USER_ROLES.BUYER]: [
    "read:product", "create:order", "read:order",
    "create:post", "read:post", "create:comment", "create:like",
  ],
  [USER_ROLES.TRANSPORT_PROVIDER]: [
    "read:transport_booking", "update:transport_booking_status",
  ],
  [USER_ROLES.AGRONOMIST]: [
    "read:disease_scan", "create:comment", "read:post",
    "create:post",
  ],
  [USER_ROLES.ADMIN]: [
    "manage:users", "manage:products", "manage:farms", "manage:orders", "read:audit_logs"
  ],
  [USER_ROLES.SUPER_ADMIN]: [
    "*" // Unrestricted access
  ]
} as const;

export type Permission = (typeof ROLE_PERMISSIONS)[keyof typeof ROLE_PERMISSIONS][number] | "*";

/**
 * Helper to check if a user role has a specific permission
 */
export function hasPermission(role: UserRole, permission: string): boolean {
  if (role === USER_ROLES.SUPER_ADMIN) return true;
  const permissions: readonly string[] = ROLE_PERMISSIONS[role] || [];
  return permissions.includes(permission);
}
