import { NestFactory } from '@nestjs/core';
import { Logger } from '@nestjs/common';
import { SeedModule } from './seed.module';
import { SubscriptionPlanSeedService } from './subscription-plan/subscription-plan-seed.service';
import { TarotCardSeedService } from './tarot-card/tarot-card-seed.service';

const logger = new Logger('Seed');

async function runSeed(): Promise<void> {
  const app = await NestFactory.createApplicationContext(SeedModule);

  try {
    const plans = app.get(SubscriptionPlanSeedService);
    await plans.run();
    logger.log('subscription_plans seeded');

    const tarot = app.get(TarotCardSeedService);
    await tarot.run();
    logger.log('tarot_cards seeded');
  } finally {
    await app.close();
  }
}

runSeed()
  .then(() => process.exit(0))
  .catch((err) => {
    logger.error('Seed failed', err as Error);
    process.exit(1);
  });
