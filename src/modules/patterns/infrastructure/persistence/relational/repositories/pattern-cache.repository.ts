import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PatternCacheEntity } from '../entities/pattern-cache.entity';

@Injectable()
export class PatternCacheRepository {
  constructor(
    @InjectRepository(PatternCacheEntity)
    private readonly repo: Repository<PatternCacheEntity>,
  ) {}

  findForWeek(userId: string, weekStart: string): Promise<PatternCacheEntity | null> {
    return this.repo.findOne({ where: { userId, weekStart } });
  }

  create(data: Partial<PatternCacheEntity>): PatternCacheEntity {
    return this.repo.create(data);
  }

  save(entity: PatternCacheEntity): Promise<PatternCacheEntity> {
    return this.repo.save(entity);
  }
}
