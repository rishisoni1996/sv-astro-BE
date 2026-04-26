import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { UserEntity } from './infrastructure/persistence/relational/entities/user.entity';
import { BirthChartEntity } from './infrastructure/persistence/relational/entities/birth-chart.entity';
import { OnboardingAnswerEntity } from './infrastructure/persistence/relational/entities/onboarding-answer.entity';
import { UserRepository } from './infrastructure/persistence/relational/repositories/user.repository';
import { BirthChartRepository } from './infrastructure/persistence/relational/repositories/birth-chart.repository';
import { OnboardingAnswerRepository } from './infrastructure/persistence/relational/repositories/onboarding-answer.repository';
import { DreamEntity } from '../dreams/infrastructure/persistence/relational/entities/dream.entity';
import { UserSubscriptionEntity } from '../subscriptions/infrastructure/persistence/relational/entities/user-subscription.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      UserEntity,
      BirthChartEntity,
      OnboardingAnswerEntity,
      DreamEntity,
      UserSubscriptionEntity,
    ]),
  ],
  controllers: [UsersController],
  providers: [UsersService, UserRepository, BirthChartRepository, OnboardingAnswerRepository],
  exports: [UsersService, UserRepository, BirthChartRepository],
})
export class UsersModule {}
