import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { IsNull, Repository } from 'typeorm';
import { UserRepository } from './infrastructure/persistence/relational/repositories/user.repository';
import { BirthChartRepository } from './infrastructure/persistence/relational/repositories/birth-chart.repository';
import { OnboardingAnswerRepository } from './infrastructure/persistence/relational/repositories/onboarding-answer.repository';
import { UserEntity } from './infrastructure/persistence/relational/entities/user.entity';
import { UserMapper } from './infrastructure/persistence/relational/mappers/user.mapper';
import { BirthChartMapper } from './infrastructure/persistence/relational/mappers/birth-chart.mapper';
import { UserDomain } from './domain/user';
import { BirthChartDomain } from './domain/birth-chart';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { UpsertBirthChartDto } from './dto/upsert-birth-chart.dto';
import { DreamEntity } from '../dreams/infrastructure/persistence/relational/entities/dream.entity';
import { UserSubscriptionEntity } from '../subscriptions/infrastructure/persistence/relational/entities/user-subscription.entity';
import { SubscriptionStatus } from '../subscriptions/subscriptions.enums';

@Injectable()
export class UsersService {
  constructor(
    private readonly userRepo: UserRepository,
    private readonly birthChartRepo: BirthChartRepository,
    private readonly onboardingRepo: OnboardingAnswerRepository,
    @InjectRepository(DreamEntity)
    private readonly dreamRepo: Repository<DreamEntity>,
    @InjectRepository(UserSubscriptionEntity)
    private readonly subscriptionRepo: Repository<UserSubscriptionEntity>,
  ) {}

  async findMe(userId: string): Promise<UserDomain> {
    const user = await this.userRepo.findById(userId, true);
    if (!user) throw new NotFoundException('User not found');
    return this.toDomain(user);
  }

  async updateMe(userId: string, dto: UpdateProfileDto): Promise<UserDomain> {
    const user = await this.userRepo.findById(userId, true);
    if (!user) throw new NotFoundException('User not found');
    if (dto.name !== undefined) {
      user.name = dto.name;
      if (!dto.initials) user.initials = buildInitials(dto.name);
    }
    if (dto.initials !== undefined) user.initials = dto.initials;
    await this.userRepo.save(user);
    return this.toDomain(user);
  }

  async getBirthChart(userId: string): Promise<BirthChartDomain | null> {
    const bc = await this.birthChartRepo.findByUserId(userId);
    return bc ? BirthChartMapper.toDomain(bc) : null;
  }

  async upsertBirthChart(userId: string, dto: UpsertBirthChartDto): Promise<BirthChartDomain> {
    const saved = await this.birthChartRepo.upsert(userId, {
      sunSign: dto.sunSign,
      moonSign: dto.moonSign,
      risingSign: dto.risingSign,
      birthDate: dto.birthDate,
      birthTime: dto.birthTime ?? null,
      birthLocation: dto.birthLocation ?? null,
    });
    return BirthChartMapper.toDomain(saved);
  }

  async submitQuizStep(
    userId: string,
    step: number,
    answer: Record<string, unknown>,
  ): Promise<void> {
    await this.onboardingRepo.upsert(userId, step, answer);
  }

  async toDomain(user: UserEntity): Promise<UserDomain> {
    const [isPremium, dreamCount] = await Promise.all([
      this.isUserPremium(user.id),
      this.countDreams(user.id),
    ]);
    let enriched = user;
    if (!user.birthChart) {
      const bc = await this.birthChartRepo.findByUserId(user.id);
      if (bc) enriched = { ...user, birthChart: bc } as UserEntity;
    }
    return UserMapper.toDomain(enriched, { isPremium, dreamCount });
  }

  private async isUserPremium(userId: string): Promise<boolean> {
    const sub = await this.subscriptionRepo.findOne({ where: { userId } });
    if (!sub) return false;
    const activeStatus =
      sub.status === SubscriptionStatus.TRIAL || sub.status === SubscriptionStatus.ACTIVE;
    if (!activeStatus) return false;
    if (!sub.expiresAt) return true;
    return sub.expiresAt.getTime() > Date.now();
  }

  private async countDreams(userId: string): Promise<number> {
    return this.dreamRepo.count({ where: { userId, deletedAt: IsNull() } });
  }
}

function buildInitials(name: string): string {
  const parts = name.trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) return 'U';
  if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
  return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
}
