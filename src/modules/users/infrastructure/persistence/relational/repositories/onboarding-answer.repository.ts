import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { OnboardingAnswerEntity } from '../entities/onboarding-answer.entity';

@Injectable()
export class OnboardingAnswerRepository {
  constructor(
    @InjectRepository(OnboardingAnswerEntity)
    private readonly repo: Repository<OnboardingAnswerEntity>,
  ) {}

  async upsert(
    userId: string,
    step: number,
    answer: Record<string, unknown>,
  ): Promise<OnboardingAnswerEntity> {
    const existing = await this.repo.findOne({ where: { userId, step } });
    if (existing) {
      existing.answerJson = answer;
      return this.repo.save(existing);
    }
    const created = this.repo.create({ userId, step, answerJson: answer });
    return this.repo.save(created);
  }
}
