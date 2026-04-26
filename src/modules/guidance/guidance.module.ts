import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { GuidanceController } from './guidance.controller';
import { GuidanceService } from './guidance.service';
import { DailyGuidanceEntity } from './infrastructure/persistence/relational/entities/daily-guidance.entity';
import { SignRevealEntity } from './infrastructure/persistence/relational/entities/sign-reveal.entity';
import { GuidanceRepository } from './infrastructure/persistence/relational/repositories/guidance.repository';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [TypeOrmModule.forFeature([DailyGuidanceEntity, SignRevealEntity]), UsersModule],
  controllers: [GuidanceController],
  providers: [GuidanceService, GuidanceRepository],
  exports: [GuidanceService],
})
export class GuidanceModule {}
