import { TarotCardDomain } from '../../../../domain/tarot-card';
import { ReadingDomain } from '../../../../domain/reading';
import { TarotCardEntity } from '../entities/tarot-card.entity';
import { TarotReadingEntity } from '../entities/tarot-reading.entity';

export class TarotCardMapper {
  static toDomain(entity: TarotCardEntity): TarotCardDomain {
    return {
      id: entity.id,
      numeral: entity.numeral,
      name: entity.name,
      keywords: entity.keywords ?? [],
      whatShows: entity.whatShows,
      appliesToToday: entity.appliesToday,
      questionToCarry: entity.question,
      deckName: entity.deckName,
    };
  }
}

export class ReadingMapper {
  static toDomain(entity: TarotReadingEntity): ReadingDomain {
    if (!entity.card) {
      throw new Error('ReadingMapper.toDomain requires eager-loaded card relation');
    }
    return {
      id: entity.id,
      card: TarotCardMapper.toDomain(entity.card),
      pulledAt: entity.pulledAt.toISOString(),
      saved: entity.saved,
    };
  }
}
