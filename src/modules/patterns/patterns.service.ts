import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { AiService } from '../../ai/ai.service';
import { formatLastSeen } from '../../utils/date-format.util';
import { UsersService } from '../users/users.service';
import { UserRepository } from '../users/infrastructure/persistence/relational/repositories/user.repository';
import { DreamEntity } from '../dreams/infrastructure/persistence/relational/entities/dream.entity';
import { InterpretationRepository } from '../interpretations/infrastructure/persistence/relational/repositories/interpretation.repository';
import { SymbolDomain } from '../interpretations/domain/symbol';
import { PatternCacheRepository } from './infrastructure/persistence/relational/repositories/pattern-cache.repository';
import { PatternCacheEntity } from './infrastructure/persistence/relational/entities/pattern-cache.entity';
import { EMOTION_COLORS, PatternCacheStatus } from './patterns.enums';
import { PatternsDomain } from './domain/patterns';
import { EmotionalThemeDomain } from './domain/emotional-theme';

const STALE_MS = 24 * 60 * 60 * 1000;

@Injectable()
export class PatternsService {
  constructor(
    private readonly cacheRepo: PatternCacheRepository,
    private readonly aiService: AiService,
    private readonly interpretationRepo: InterpretationRepository,
    private readonly usersService: UsersService,
    private readonly userRepo: UserRepository,
    @InjectRepository(DreamEntity)
    private readonly dreamRepo: Repository<DreamEntity>,
    private readonly dataSource: DataSource,
  ) {}

  async getCurrentWeek(userId: string): Promise<PatternsDomain> {
    const weekStart = mondayOfWeek(new Date()).toISOString().slice(0, 10);
    let cache = await this.cacheRepo.findForWeek(userId, weekStart);

    const needsRefresh =
      !cache ||
      cache.status !== PatternCacheStatus.DONE ||
      !cache.generatedAt ||
      Date.now() - new Date(cache.generatedAt).getTime() > STALE_MS;

    if (needsRefresh) {
      cache = await this.regenerate(userId, weekStart, cache ?? null);
    }

    const isPremium = await this.isPremium(userId);

    const symbols = await this.buildSymbolDomains(userId);
    const themes = await this.buildThemes(userId);

    return {
      weekStart,
      recurringSymbols: symbols,
      themes,
      weeklySummary: isPremium ? (cache ? cache.summary : null) : null,
      isSummaryLocked: !isPremium,
    };
  }

  async getAllTimeSymbols(userId: string): Promise<SymbolDomain[]> {
    return this.buildSymbolDomains(userId);
  }

  private async buildSymbolDomains(userId: string): Promise<SymbolDomain[]> {
    const aggregates = await this.interpretationRepo.symbolAggregates(userId);
    const rows = Array.from(aggregates.entries())
      .map(([name, agg]) => ({ name, ...agg }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 10);

    if (rows.length === 0) return [];

    const emojiLookup = await this.dataSource.query<{ name: string; emoji: string }[]>(
      `SELECT DISTINCT ON (s.name) s.name, s.emoji
         FROM dream_symbols s
         JOIN dream_interpretations i ON i.id = s.interpretation_id
         JOIN dreams d ON d.id = i.dream_id
        WHERE d.user_id = $1 AND d.deleted_at IS NULL
        ORDER BY s.name, s."sort_order" ASC`,
      [userId],
    );
    const emojiMap = new Map(emojiLookup.map((r) => [r.name, r.emoji]));

    return rows.map((r, i) => ({
      id: `symbol-${i}`,
      emoji: emojiMap.get(r.name) ?? '✨',
      name: r.name,
      occurrenceCount: r.count,
      lastSeenLabel: formatLastSeen(r.lastSeenAt),
    }));
  }

  private async buildThemes(userId: string): Promise<EmotionalThemeDomain[]> {
    const rows = await this.dataSource.query<{ tag: string; cnt: string }[]>(
      `SELECT tag, COUNT(*)::int AS cnt
         FROM (
           SELECT unnest(emotion_tags) AS tag
             FROM dreams
            WHERE user_id = $1
              AND deleted_at IS NULL
              AND recorded_at >= now() - interval '30 days'
         ) t
        GROUP BY tag
        ORDER BY cnt DESC`,
      [userId],
    );
    const total = rows.reduce((sum, r) => sum + Number(r.cnt), 0);
    if (total === 0) return [];
    return rows.map((r) => ({
      label: r.tag,
      percent: Math.round((Number(r.cnt) / total) * 100),
      colorHex: EMOTION_COLORS[r.tag] ?? '#8B6BC4',
    }));
  }

  private async regenerate(
    userId: string,
    weekStart: string,
    existing: PatternCacheEntity | null,
  ): Promise<PatternCacheEntity> {
    const cache =
      existing ?? this.cacheRepo.create({ userId, weekStart, status: PatternCacheStatus.PENDING });

    const titles = await this.weekDreamTitles(userId, weekStart);
    const aggregates = await this.interpretationRepo.symbolAggregates(userId);
    const symbolNames = Array.from(aggregates.keys()).slice(0, 5);

    let summary: string | null = null;
    if (titles.length > 0) {
      summary = await this.aiService.generateWeeklySummary(titles, symbolNames);
    }

    cache.symbolsJson = Array.from(aggregates.entries()).map(([name, agg]) => ({
      emoji: '✨',
      name,
      count: agg.count,
      lastSeenLabel: formatLastSeen(agg.lastSeenAt),
    }));
    cache.themesJson = [];
    cache.summary = summary;
    cache.status = PatternCacheStatus.DONE;
    cache.generatedAt = new Date();
    return this.cacheRepo.save(cache);
  }

  private async weekDreamTitles(userId: string, weekStart: string): Promise<string[]> {
    const rows = await this.dreamRepo.find({
      where: { userId },
      select: ['id', 'title', 'content', 'recordedAt'],
    });
    const weekStartDate = new Date(weekStart).getTime();
    return rows
      .filter((r) => new Date(r.recordedAt).getTime() >= weekStartDate)
      .map((r) => r.title ?? r.content.slice(0, 60))
      .slice(0, 20);
  }

  private async isPremium(userId: string): Promise<boolean> {
    const user = await this.userRepo.findById(userId);
    if (!user) return false;
    const d = await this.usersService.toDomain(user);
    return d.isPremium;
  }
}

function mondayOfWeek(date: Date): Date {
  const d = new Date(date);
  const day = d.getUTCDay();
  const diff = (day === 0 ? -6 : 1) - day;
  d.setUTCDate(d.getUTCDate() + diff);
  d.setUTCHours(0, 0, 0, 0);
  return d;
}
