import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ReadingsController } from './readings.controller';
import { ReadingsService } from './readings.service';
import { TarotCardEntity } from './infrastructure/persistence/relational/entities/tarot-card.entity';
import { TarotReadingEntity } from './infrastructure/persistence/relational/entities/tarot-reading.entity';
import { ReadingsRepository } from './infrastructure/persistence/relational/repositories/readings.repository';

@Module({
  imports: [TypeOrmModule.forFeature([TarotCardEntity, TarotReadingEntity])],
  controllers: [ReadingsController],
  providers: [ReadingsService, ReadingsRepository],
  exports: [ReadingsService],
})
export class ReadingsModule {}
