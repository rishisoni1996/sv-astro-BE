import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SubscriptionPlanEntity } from '../../../../modules/subscriptions/infrastructure/persistence/relational/entities/subscription-plan.entity';
import { SubscriptionPlanSeedService } from './subscription-plan-seed.service';

@Module({
  imports: [TypeOrmModule.forFeature([SubscriptionPlanEntity])],
  providers: [SubscriptionPlanSeedService],
  exports: [SubscriptionPlanSeedService],
})
export class SubscriptionPlanSeedModule {}
