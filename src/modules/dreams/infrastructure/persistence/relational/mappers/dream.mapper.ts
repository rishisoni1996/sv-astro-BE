import {
  formatClock,
  formatDayName,
  formatDayNumber,
} from '../../../../../../utils/date-format.util';
import { DreamDomain } from '../../../../domain/dream';
import { DreamEntity } from '../entities/dream.entity';

export class DreamMapper {
  static toDomain(entity: DreamEntity, hasInterpretation: boolean): DreamDomain {
    const d = new DreamDomain();
    d.id = entity.id;
    d.title = entity.title;
    d.content = entity.content;
    d.typeTags = entity.typeTags ?? [];
    d.emotionTags = entity.emotionTags ?? [];
    d.recordedAt = entity.recordedAt.toISOString();
    d.dateNumber = formatDayNumber(entity.recordedAt);
    d.dateDay = formatDayName(entity.recordedAt);
    d.timestamp = formatClock(entity.recordedAt);
    d.hasInterpretation = hasInterpretation;
    return d;
  }
}
