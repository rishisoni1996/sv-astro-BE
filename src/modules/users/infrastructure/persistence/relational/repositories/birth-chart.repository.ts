import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { BirthChartEntity } from '../entities/birth-chart.entity';

@Injectable()
export class BirthChartRepository {
  constructor(
    @InjectRepository(BirthChartEntity)
    private readonly repo: Repository<BirthChartEntity>,
  ) {}

  findByUserId(userId: string): Promise<BirthChartEntity | null> {
    return this.repo.findOne({ where: { userId } });
  }

  async upsert(
    userId: string,
    data: Omit<Partial<BirthChartEntity>, 'id' | 'userId'>,
  ): Promise<BirthChartEntity> {
    const existing = await this.repo.findOne({ where: { userId } });
    if (existing) {
      Object.assign(existing, data);
      return this.repo.save(existing);
    }
    const created = this.repo.create({ userId, ...data });
    return this.repo.save(created);
  }
}
