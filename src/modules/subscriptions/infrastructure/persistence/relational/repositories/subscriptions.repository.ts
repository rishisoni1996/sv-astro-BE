import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SubscriptionPlanEntity } from '../entities/subscription-plan.entity';
import { UserSubscriptionEntity } from '../entities/user-subscription.entity';

@Injectable()
export class SubscriptionsRepository {
  constructor(
    @InjectRepository(SubscriptionPlanEntity)
    private readonly planRepo: Repository<SubscriptionPlanEntity>,
    @InjectRepository(UserSubscriptionEntity)
    private readonly subRepo: Repository<UserSubscriptionEntity>,
  ) {}

  listPlans(): Promise<SubscriptionPlanEntity[]> {
    return this.planRepo.find({ order: { sortOrder: 'ASC' } });
  }

  findPlanById(id: string): Promise<SubscriptionPlanEntity | null> {
    return this.planRepo.findOne({ where: { id } });
  }

  findByUser(userId: string): Promise<UserSubscriptionEntity | null> {
    return this.subRepo.findOne({ where: { userId }, relations: ['plan'] });
  }

  create(data: Partial<UserSubscriptionEntity>): UserSubscriptionEntity {
    return this.subRepo.create(data);
  }

  save(sub: UserSubscriptionEntity): Promise<UserSubscriptionEntity> {
    return this.subRepo.save(sub);
  }
}
