import {
  BadRequestException,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { formatRenewsLabel } from '../../utils/date-format.util';
import { SubscriptionsRepository } from './infrastructure/persistence/relational/repositories/subscriptions.repository';
import { SubscriptionPlanEntity } from './infrastructure/persistence/relational/entities/subscription-plan.entity';
import { UserSubscriptionEntity } from './infrastructure/persistence/relational/entities/user-subscription.entity';
import { SubscriptionProvider, SubscriptionStatus } from './subscriptions.enums';
import { SubscriptionPlanDomain } from './domain/plan';
import { SubscriptionDomain } from './domain/subscription';
import { ValidateIapDto } from './dto/validate-iap.dto';
import { RestorePurchasesDto } from './dto/restore-purchases.dto';
import { AppleIapClient } from './iap/apple-iap.client';
import { GoogleIapClient } from './iap/google-iap.client';

const TRIAL_MS = 3 * 24 * 60 * 60 * 1000;

@Injectable()
export class SubscriptionsService {
  constructor(
    private readonly repo: SubscriptionsRepository,
    private readonly appleIap: AppleIapClient,
    private readonly googleIap: GoogleIapClient,
  ) {}

  async listPlans(): Promise<SubscriptionPlanDomain[]> {
    const rows = await this.repo.listPlans();
    return rows.map(toPlanDomain);
  }

  async me(userId: string): Promise<SubscriptionDomain | null> {
    const sub = await this.repo.findByUser(userId);
    if (!sub) return null;
    return toSubscriptionDomain(sub);
  }

  async validate(userId: string, dto: ValidateIapDto): Promise<SubscriptionDomain> {
    const plan = await this.repo.findPlanById(dto.planId);
    if (!plan) throw new BadRequestException('Unknown plan');

    let expiresAt: Date | null = null;
    let provider: SubscriptionProvider | null = null;
    let status: SubscriptionStatus = SubscriptionStatus.ACTIVE;

    if (dto.provider === 'apple') {
      const result = await this.appleIap.verify(dto.receiptToken);
      if (!result.ok) throw new UnauthorizedException('Apple receipt invalid');
      expiresAt = result.expiresAt;
      provider = SubscriptionProvider.APPLE;
    } else if (dto.provider === 'google') {
      const result = await this.googleIap.verify(dto.planId, dto.receiptToken);
      if (!result.ok) throw new UnauthorizedException('Google receipt invalid');
      expiresAt = result.expiresAt;
      provider = SubscriptionProvider.GOOGLE;
    } else {
      provider = SubscriptionProvider.STRIPE;
    }

    const existing = await this.repo.findByUser(userId);
    let trialEndsAt: Date | null = null;
    if (!existing) {
      status = SubscriptionStatus.TRIAL;
      trialEndsAt = new Date(Date.now() + TRIAL_MS);
      expiresAt = expiresAt ?? new Date(Date.now() + TRIAL_MS);
    }

    const entity =
      existing ??
      this.repo.create({
        userId,
        planId: plan.id,
      });
    entity.planId = plan.id;
    entity.status = status;
    entity.provider = provider;
    entity.receiptToken = dto.receiptToken;
    entity.expiresAt = expiresAt;
    entity.trialEndsAt = trialEndsAt ?? entity.trialEndsAt ?? null;
    entity.autoRenew = true;

    const saved = await this.repo.save(entity);
    const withPlan = await this.repo.findByUser(userId);
    return toSubscriptionDomain(withPlan ?? saved);
  }

  async restore(userId: string, dto: RestorePurchasesDto): Promise<SubscriptionDomain> {
    return this.validate(userId, {
      provider: dto.provider,
      receiptToken: dto.receiptToken,
      planId: 'annual',
    });
  }

  async cancel(userId: string): Promise<void> {
    const sub = await this.repo.findByUser(userId);
    if (!sub) throw new NotFoundException('No subscription to cancel');
    sub.autoRenew = false;
    await this.repo.save(sub);
  }
}

function toPlanDomain(entity: SubscriptionPlanEntity): SubscriptionPlanDomain {
  return {
    id: entity.id,
    title: entity.title,
    price: `$${Number(entity.price).toFixed(2)}`,
    unit: entity.unit,
    badge: entity.badge,
  };
}

function toSubscriptionDomain(entity: UserSubscriptionEntity): SubscriptionDomain {
  const isPremium =
    (entity.status === SubscriptionStatus.ACTIVE || entity.status === SubscriptionStatus.TRIAL) &&
    (!entity.expiresAt || entity.expiresAt.getTime() > Date.now());

  return {
    planId: entity.planId,
    status: entity.status,
    isPremium,
    trialEndsAt: entity.trialEndsAt ? entity.trialEndsAt.toISOString() : null,
    expiresAt: entity.expiresAt ? entity.expiresAt.toISOString() : null,
    planLabel: entity.plan
      ? `Premium · ${capitalize(entity.plan.title.toLowerCase())}`
      : `Premium · ${capitalize(entity.planId)}`,
    renewsLabel: entity.expiresAt ? formatRenewsLabel(entity.expiresAt) : '',
  };
}

function capitalize(s: string): string {
  return s.length === 0 ? s : s[0].toUpperCase() + s.slice(1);
}
