import { ForbiddenException } from '@nestjs/common';

export interface PremiumAware {
  isPremium: boolean;
}

export function assertPremium(user: PremiumAware, feature: string): void {
  if (!user.isPremium) {
    throw new ForbiddenException(`${feature} requires a premium subscription.`);
  }
}
