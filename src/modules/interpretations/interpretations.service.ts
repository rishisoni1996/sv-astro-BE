import { Injectable, NotFoundException } from '@nestjs/common';
import { AiService } from '../../ai/ai.service';
import { formatLastSeen } from '../../utils/date-format.util';
import { DreamRepository } from '../dreams/infrastructure/persistence/relational/repositories/dream.repository';
import { UsersService } from '../users/users.service';
import { UserRepository } from '../users/infrastructure/persistence/relational/repositories/user.repository';
import { InterpretationRepository } from './infrastructure/persistence/relational/repositories/interpretation.repository';
import { InterpretationStatus } from './interpretations.enums';
import { InterpretationDomain } from './domain/interpretation';
import { SymbolDomain } from './domain/symbol';
import { DreamSymbolEntity } from './infrastructure/persistence/relational/entities/dream-symbol.entity';

@Injectable()
export class InterpretationsService {
  constructor(
    private readonly aiService: AiService,
    private readonly repo: InterpretationRepository,
    private readonly dreamRepo: DreamRepository,
    private readonly usersService: UsersService,
    private readonly userRepo: UserRepository,
  ) {}

  async trigger(userId: string, dreamId: string): Promise<InterpretationDomain> {
    const dream = await this.dreamRepo.findByIdForUser(dreamId, userId);
    if (!dream) throw new NotFoundException('Dream not found');

    const existing = await this.repo.findByDreamId(dreamId);
    if (existing && existing.status === InterpretationStatus.DONE) {
      return this.toDomain(userId, existing);
    }

    const record =
      existing ??
      this.repo.create({
        dreamId,
        status: InterpretationStatus.PROCESSING,
      });
    record.status = InterpretationStatus.PROCESSING;
    const saved = await this.repo.save(record);

    const result = await this.aiService.generateInterpretation(
      dream.content,
      dream.typeTags ?? [],
      dream.emotionTags ?? [],
    );

    if (!result) {
      saved.status = InterpretationStatus.FAILED;
      await this.repo.save(saved);
      return this.toDomain(userId, saved);
    }

    saved.coreMeaning = result.coreMeaning;
    saved.whatReveals = result.whatReveals;
    saved.guidance = result.guidance;
    saved.status = InterpretationStatus.DONE;
    const updated = await this.repo.save(saved);
    await this.repo.replaceSymbols(updated.id, result.symbols.slice(0, 5));

    const fresh = await this.repo.findByDreamId(dreamId);
    if (!fresh) throw new NotFoundException('Interpretation missing after save');
    return this.toDomain(userId, fresh);
  }

  async get(userId: string, dreamId: string): Promise<InterpretationDomain> {
    const dream = await this.dreamRepo.findByIdForUser(dreamId, userId);
    if (!dream) throw new NotFoundException('Dream not found');
    const interp = await this.repo.findByDreamId(dreamId);
    if (!interp) throw new NotFoundException('Interpretation not yet generated');
    return this.toDomain(userId, interp);
  }

  private async toDomain(
    userId: string,
    entity: Awaited<ReturnType<InterpretationRepository['findByDreamId']>>,
  ): Promise<InterpretationDomain> {
    if (!entity) throw new NotFoundException('Interpretation missing');
    const user = await this.userRepo.findById(userId);
    const isPremium = user ? await this.isPremiumSafe(user.id) : false;

    const aggregates = await this.repo.symbolAggregates(userId);
    const symbols: SymbolDomain[] = (entity.symbols ?? []).map((s: DreamSymbolEntity) => {
      const agg = aggregates.get(s.name);
      return {
        id: s.id,
        emoji: s.emoji,
        name: s.name,
        occurrenceCount: agg?.count ?? 1,
        lastSeenLabel: agg ? formatLastSeen(agg.lastSeenAt) : 'Just now',
      };
    });

    const domain: InterpretationDomain = {
      id: entity.id,
      dreamId: entity.dreamId,
      status: entity.status,
      coreMeaning: entity.coreMeaning,
      whatReveals: isPremium ? entity.whatReveals : null,
      guidance: isPremium ? entity.guidance : null,
      symbols,
      isPremiumLocked: !isPremium,
    };
    return domain;
  }

  private async isPremiumSafe(userId: string): Promise<boolean> {
    const u = await this.userRepo.findById(userId);
    if (!u) return false;
    const domain = await this.usersService.toDomain(u);
    return domain.isPremium;
  }
}
