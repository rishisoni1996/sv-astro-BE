import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { DreamInterpretationEntity } from '../entities/dream-interpretation.entity';
import { DreamSymbolEntity } from '../entities/dream-symbol.entity';

@Injectable()
export class InterpretationRepository {
  constructor(
    @InjectRepository(DreamInterpretationEntity)
    private readonly interpretationRepo: Repository<DreamInterpretationEntity>,
    @InjectRepository(DreamSymbolEntity)
    private readonly symbolRepo: Repository<DreamSymbolEntity>,
  ) {}

  findByDreamId(dreamId: string): Promise<DreamInterpretationEntity | null> {
    return this.interpretationRepo.findOne({
      where: { dreamId },
      relations: ['symbols'],
    });
  }

  create(data: Partial<DreamInterpretationEntity>): DreamInterpretationEntity {
    return this.interpretationRepo.create(data);
  }

  save(entity: DreamInterpretationEntity): Promise<DreamInterpretationEntity> {
    return this.interpretationRepo.save(entity);
  }

  async replaceSymbols(
    interpretationId: string,
    symbols: { emoji: string; name: string }[],
  ): Promise<DreamSymbolEntity[]> {
    await this.symbolRepo.delete({ interpretationId });
    if (symbols.length === 0) return [];
    const rows = symbols.map((s, i) =>
      this.symbolRepo.create({
        interpretationId,
        emoji: s.emoji,
        name: s.name,
        occurrenceCount: 1,
        lastSeenLabel: null,
        sortOrder: i,
      }),
    );
    return this.symbolRepo.save(rows);
  }

  /**
   * For a given user, returns map of symbol-name → { count, lastSeenAt }.
   */
  async symbolAggregates(
    userId: string,
  ): Promise<Map<string, { count: number; lastSeenAt: Date }>> {
    const rows = await this.symbolRepo
      .createQueryBuilder('s')
      .innerJoin('dream_interpretations', 'i', 'i.id = s.interpretation_id')
      .innerJoin('dreams', 'd', 'd.id = i.dream_id')
      .where('d.user_id = :userId', { userId })
      .andWhere('d.deleted_at IS NULL')
      .select('s.name', 'name')
      .addSelect('COUNT(s.id)', 'count')
      .addSelect('MAX(d.recorded_at)', 'lastSeenAt')
      .groupBy('s.name')
      .getRawMany<{ name: string; count: string; lastSeenAt: Date }>();

    const map = new Map<string, { count: number; lastSeenAt: Date }>();
    for (const r of rows) {
      map.set(r.name, { count: Number(r.count), lastSeenAt: new Date(r.lastSeenAt) });
    }
    return map;
  }
}
