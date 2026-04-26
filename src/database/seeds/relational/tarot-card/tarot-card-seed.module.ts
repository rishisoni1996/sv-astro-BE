import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TarotCardEntity } from '../../../../modules/readings/infrastructure/persistence/relational/entities/tarot-card.entity';
import { TarotCardSeedService } from './tarot-card-seed.service';

@Module({
  imports: [TypeOrmModule.forFeature([TarotCardEntity])],
  providers: [TarotCardSeedService],
  exports: [TarotCardSeedService],
})
export class TarotCardSeedModule {}
