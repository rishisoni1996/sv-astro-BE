import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DreamsController } from './dreams.controller';
import { DreamsService } from './dreams.service';
import { DreamEntity } from './infrastructure/persistence/relational/entities/dream.entity';
import { DreamRepository } from './infrastructure/persistence/relational/repositories/dream.repository';
import { DreamInterpretationEntity } from '../interpretations/infrastructure/persistence/relational/entities/dream-interpretation.entity';

@Module({
  imports: [TypeOrmModule.forFeature([DreamEntity, DreamInterpretationEntity])],
  controllers: [DreamsController],
  providers: [DreamsService, DreamRepository],
  exports: [DreamsService, DreamRepository],
})
export class DreamsModule {}
