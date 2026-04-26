import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { TarotCardEntity } from '../../../../modules/readings/infrastructure/persistence/relational/entities/tarot-card.entity';
import { TAROT_DECK_NAME, TAROT_SEED } from './tarot-card-seed.data';

@Injectable()
export class TarotCardSeedService {
  constructor(
    @InjectRepository(TarotCardEntity)
    private readonly repo: Repository<TarotCardEntity>,
  ) {}

  async run(): Promise<void> {
    const existing = await this.repo.count();
    if (existing === TAROT_SEED.length) return;

    for (const card of TAROT_SEED) {
      const row = await this.repo.findOne({ where: { sortOrder: card.sortOrder } });
      if (row) continue;
      await this.repo.save(
        this.repo.create({
          numeral: card.numeral,
          name: card.name,
          keywords: card.keywords,
          whatShows: card.whatShows,
          appliesToday: card.appliesToday,
          question: card.question,
          deckName: TAROT_DECK_NAME,
          sortOrder: card.sortOrder,
        }),
      );
    }
  }
}
