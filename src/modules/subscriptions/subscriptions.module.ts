import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SubscriptionsController } from './subscriptions.controller';
import { SubscriptionsService } from './subscriptions.service';
import { SubscriptionPlanEntity } from './infrastructure/persistence/relational/entities/subscription-plan.entity';
import { UserSubscriptionEntity } from './infrastructure/persistence/relational/entities/user-subscription.entity';
import { SubscriptionsRepository } from './infrastructure/persistence/relational/repositories/subscriptions.repository';
import { AppleIapClient } from './iap/apple-iap.client';
import { GoogleIapClient } from './iap/google-iap.client';

@Module({
  imports: [TypeOrmModule.forFeature([SubscriptionPlanEntity, UserSubscriptionEntity])],
  controllers: [SubscriptionsController],
  providers: [SubscriptionsService, SubscriptionsRepository, AppleIapClient, GoogleIapClient],
  exports: [SubscriptionsService, SubscriptionsRepository],
})
export class SubscriptionsModule {}
