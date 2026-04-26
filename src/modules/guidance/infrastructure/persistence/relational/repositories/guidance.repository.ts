import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { DailyGuidanceEntity } from '../entities/daily-guidance.entity';
import { SignRevealEntity } from '../entities/sign-reveal.entity';
import { SignPositionEnum } from '../../../../guidance.enums';

@Injectable()
export class GuidanceRepository {
  constructor(
    @InjectRepository(DailyGuidanceEntity)
    private readonly dailyRepo: Repository<DailyGuidanceEntity>,
    @InjectRepository(SignRevealEntity)
    private readonly signRepo: Repository<SignRevealEntity>,
  ) {}

  findDaily(userId: string, date: string): Promise<DailyGuidanceEntity | null> {
    return this.dailyRepo.findOne({ where: { userId, guidanceDate: date } });
  }

  createDaily(data: Partial<DailyGuidanceEntity>): DailyGuidanceEntity {
    return this.dailyRepo.create(data);
  }

  saveDaily(entity: DailyGuidanceEntity): Promise<DailyGuidanceEntity> {
    return this.dailyRepo.save(entity);
  }

  findSignReveals(userId: string): Promise<SignRevealEntity[]> {
    return this.signRepo.find({ where: { userId } });
  }

  findSignReveal(userId: string, position: SignPositionEnum): Promise<SignRevealEntity | null> {
    return this.signRepo.findOne({ where: { userId, position } });
  }

  async saveSignReveal(entity: SignRevealEntity): Promise<SignRevealEntity> {
    return this.signRepo.save(entity);
  }

  createSignReveal(data: Partial<SignRevealEntity>): SignRevealEntity {
    return this.signRepo.create(data);
  }

  async deleteSignReveals(userId: string): Promise<void> {
    await this.signRepo.delete({ userId });
  }
}
