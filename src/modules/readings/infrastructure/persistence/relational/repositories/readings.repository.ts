import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { TarotCardEntity } from '../entities/tarot-card.entity';
import { TarotReadingEntity } from '../entities/tarot-reading.entity';

@Injectable()
export class ReadingsRepository {
  constructor(
    @InjectRepository(TarotCardEntity)
    private readonly cardRepo: Repository<TarotCardEntity>,
    @InjectRepository(TarotReadingEntity)
    private readonly readingRepo: Repository<TarotReadingEntity>,
  ) {}

  findCardBySortOrder(sortOrder: number): Promise<TarotCardEntity | null> {
    return this.cardRepo.findOne({ where: { sortOrder } });
  }

  countCards(): Promise<number> {
    return this.cardRepo.count();
  }

  findRandomCard(): Promise<TarotCardEntity | null> {
    return this.cardRepo.createQueryBuilder('c').orderBy('random()').limit(1).getOne();
  }

  findDailyReading(userId: string, date: string): Promise<TarotReadingEntity | null> {
    return this.readingRepo.findOne({ where: { userId, dailyDate: date } });
  }

  createReading(data: Partial<TarotReadingEntity>): TarotReadingEntity {
    return this.readingRepo.create(data);
  }

  saveReading(entity: TarotReadingEntity): Promise<TarotReadingEntity> {
    return this.readingRepo.save(entity);
  }

  findReadingForUser(id: string, userId: string): Promise<TarotReadingEntity | null> {
    return this.readingRepo.findOne({ where: { id, userId } });
  }

  listSaved(userId: string): Promise<TarotReadingEntity[]> {
    return this.readingRepo.find({
      where: { userId, saved: true },
      order: { pulledAt: 'DESC' },
    });
  }

  async deleteReading(id: string): Promise<void> {
    await this.readingRepo.delete(id);
  }
}
