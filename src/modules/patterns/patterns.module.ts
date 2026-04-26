import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PatternsController } from './patterns.controller';
import { PatternsService } from './patterns.service';
import { PatternCacheEntity } from './infrastructure/persistence/relational/entities/pattern-cache.entity';
import { PatternCacheRepository } from './infrastructure/persistence/relational/repositories/pattern-cache.repository';
import { DreamEntity } from '../dreams/infrastructure/persistence/relational/entities/dream.entity';
import { InterpretationsModule } from '../interpretations/interpretations.module';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([PatternCacheEntity, DreamEntity]),
    InterpretationsModule,
    UsersModule,
  ],
  controllers: [PatternsController],
  providers: [PatternsService, PatternCacheRepository],
  exports: [PatternsService],
})
export class PatternsModule {}
