export enum SubscriptionStatus {
  TRIAL = 'trial',
  ACTIVE = 'active',
  CANCELLED = 'cancelled',
  EXPIRED = 'expired',
}

export enum SubscriptionProvider {
  APPLE = 'apple',
  GOOGLE = 'google',
  STRIPE = 'stripe',
}

export const VALID_PLAN_IDS = ['weekly', 'monthly', 'annual'] as const;
export type PlanId = (typeof VALID_PLAN_IDS)[number];
