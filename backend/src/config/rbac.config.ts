export enum RoleCode {
  ADMIN = 'admin',
  MEDICAL_STAFF = 'medical_staff',
  FAMILY = 'family',
  ELDER = 'elder'
}

export const ROLE_NAMES: Record<RoleCode, string> = {
  [RoleCode.ADMIN]: '管理员',
  [RoleCode.MEDICAL_STAFF]: '医护人员',
  [RoleCode.FAMILY]: '家属',
  [RoleCode.ELDER]: '老人'
};

export const ROLE_LEVELS: Record<RoleCode, number> = {
  [RoleCode.ADMIN]: 4,
  [RoleCode.MEDICAL_STAFF]: 3,
  [RoleCode.FAMILY]: 2,
  [RoleCode.ELDER]: 1
};

export const isValidRole = (role: string): role is RoleCode => {
  return Object.values(RoleCode).includes(role as RoleCode);
};

export const getRoleName = (roleCode: RoleCode): string => {
  return ROLE_NAMES[roleCode];
};

export const getRoleLevel = (roleCode: RoleCode): number => {
  return ROLE_LEVELS[roleCode];
};

export const compareRoles = (role1: RoleCode, role2: RoleCode): number => {
  return ROLE_LEVELS[role1] - ROLE_LEVELS[role2];
};

export const hasHigherOrEqualRole = (userRole: RoleCode, requiredRole: RoleCode): boolean => {
  return ROLE_LEVELS[userRole] >= ROLE_LEVELS[requiredRole];
};
