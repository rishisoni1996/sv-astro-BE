import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SubscriptionPlanEntity } from '../../../../modules/subscriptions/infrastructure/persistence/relational/entities/subscription-plan.entity';

interface PlanSeed {
  id: string;
  title: string;
  price: string;
  unit: string;
  badge: string | null;
  sortOrder: number;
}

const PLANS: PlanSeed[] = [
  { id: 'weekly', title: 'WEEKLY', price: '7.99', unit: '/wk', badge: null, sortOrder: 0 },
  {
    id: 'annual',
    title: 'ANNUAL',
    price: '49.99',
    unit: '/yr',
    badge: 'SAVE 87%',
    sortOrder: 1,
  },
  { id: 'monthly', title: 'MONTHLY', price: '14.99', unit: '/mo', badge: null, sortOrder: 2 },
];

@Injectable()
export class SubscriptionPlanSeedService {
  constructor(
    @InjectRepository(SubscriptionPlanEntity)
    private readonly repo: Repository<SubscriptionPlanEntity>,
  ) {}

  async run(): Promise<void> {
    for (const plan of PLANS) {
      const existing = await this.repo.findOne({ where: { id: plan.id } });
      if (existing) continue;
      await this.repo.save(this.repo.create(plan));
    }
  }
}
