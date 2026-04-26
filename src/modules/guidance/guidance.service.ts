import { Injectable } from '@nestjs/common';
import { AiService } from '../../ai/ai.service';
import { formatDateBadge } from '../../utils/date-format.util';
import { BirthChartRepository } from '../users/infrastructure/persistence/relational/repositories/birth-chart.repository';
import { UserRepository } from '../users/infrastructure/persistence/relational/repositories/user.repository';
import { GuidanceRepository } from './infrastructure/persistence/relational/repositories/guidance.repository';
import { DailyGuidanceDomain } from './domain/daily-guidance';
import { SignRevealDomain } from './domain/sign-reveal';
import { DailyGuidanceStatus, SignPositionEnum } from './guidance.enums';

const FALLBACK_GREETING = 'Welcome back';
const FALLBACK_HEADLINE = 'Today invites you to listen to what feels quiet but steady.';
const FALLBACK_SUBTEXT =
  'Small, attentive choices move you forward. Stay curious; trust what catches your attention.';

@Injectable()
export class GuidanceService {
  constructor(
    private readonly repo: GuidanceRepository,
    private readonly ai: AiService,
    private readonly birthChartRepo: BirthChartRepository,
    private readonly userRepo: UserRepository,
  ) {}

  async getDaily(userId: string): Promise<DailyGuidanceDomain> {
    const today = new Date();
    const dateStr = today.toISOString().slice(0, 10);
    const existing = await this.repo.findDaily(userId, dateStr);
    if (existing) return this.toDailyDomain(existing, today);

    const birthChart = await this.birthChartRepo.findByUserId(userId);
    const user = await this.userRepo.findById(userId);
    const name = user?.name.split(' ')[0] ?? 'friend';

    const result = birthChart
      ? await this.ai.generateGuidance(
          birthChart.sunSign,
          birthChart.moonSign,
          birthChart.risingSign,
          today,
        )
      : null;

    const entity = this.repo.createDaily({
      userId,
      guidanceDate: dateStr,
      greeting: result?.greeting ?? `${FALLBACK_GREETING}, ${name}`,
      headline: result?.headline ?? FALLBACK_HEADLINE,
      subtext: result?.subtext ?? FALLBACK_SUBTEXT,
      astroContext: result?.astroContext ?? null,
      status: DailyGuidanceStatus.DONE,
    });
    const saved = await this.repo.saveDaily(entity);
    return this.toDailyDomain(saved, today);
  }

  async getSignReveals(userId: string): Promise<SignRevealDomain[]> {
    const birthChart = await this.birthChartRepo.findByUserId(userId);
    if (!birthChart) return [];

    const existing = await this.repo.findSignReveals(userId);
    const byPos = new Map(existing.map((r) => [r.position, r]));

    const toGenerate: { position: SignPositionEnum; sign: string }[] = [];
    const positions: { position: SignPositionEnum; sign: string }[] = [
      { position: SignPositionEnum.SUN, sign: birthChart.sunSign },
      { position: SignPositionEnum.MOON, sign: birthChart.moonSign },
      { position: SignPositionEnum.RISING, sign: birthChart.risingSign },
    ];
    for (const p of positions) if (!byPos.has(p.position)) toGenerate.push(p);

    if (toGenerate.length > 0) {
      const generated = await Promise.all(
        toGenerate.map(async (p) => {
          const desc = await this.ai.generateSignReveal(p.sign, p.position);
          return { ...p, description: desc ?? staticFallback(p.sign, p.position) };
        }),
      );
      for (const g of generated) {
        const row = this.repo.createSignReveal({
          userId,
          position: g.position,
          signName: g.sign,
          description: g.description,
        });
        const saved = await this.repo.saveSignReveal(row);
        byPos.set(g.position, saved);
      }
    }

    return positions.map((p) => {
      const row = byPos.get(p.position);
      return {
        position: p.position,
        signName: row?.signName ?? p.sign,
        label: `YOUR ${p.position.toUpperCase()}`,
        description: row?.description ?? staticFallback(p.sign, p.position),
      };
    });
  }

  async regenerateSignReveals(userId: string): Promise<SignRevealDomain[]> {
    await this.repo.deleteSignReveals(userId);
    return this.getSignReveals(userId);
  }

  private toDailyDomain(
    entity: {
      guidanceDate: string;
      greeting: string;
      headline: string;
      subtext: string;
    },
    today: Date,
  ): DailyGuidanceDomain {
    return {
      date: entity.guidanceDate,
      dateBadge: formatDateBadge(today),
      greeting: entity.greeting,
      headline: entity.headline,
      subtext: entity.subtext,
    };
  }
}

function staticFallback(sign: string, position: SignPositionEnum): string {
  return `Your ${position} in ${sign} colors how you show up in the world — a quiet signature the universe keeps returning to. Let it guide you without forcing the path.`;
}
