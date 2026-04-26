import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { DreamEntity } from '../entities/dream.entity';

export interface ListDreamsFilter {
  userId: string;
  filter?: 'all' | 'week' | 'month';
  search?: string;
  page: number;
  limit: number;
}

@Injectable()
export class DreamRepository {
  constructor(
    @InjectRepository(DreamEntity)
    private readonly repo: Repository<DreamEntity>,
  ) {}

  create(data: Partial<DreamEntity>): DreamEntity {
    return this.repo.create(data);
  }

  save(dream: DreamEntity): Promise<DreamEntity> {
    return this.repo.save(dream);
  }

  findByIdForUser(id: string, userId: string): Promise<DreamEntity | null> {
    return this.repo.findOne({ where: { id, userId } });
  }

  async softDelete(id: string): Promise<void> {
    await this.repo.softDelete(id);
  }

  async list(opts: ListDreamsFilter): Promise<{ rows: DreamEntity[]; total: number }> {
    const qb = this.repo
      .createQueryBuilder('d')
      .where('d.user_id = :userId', { userId: opts.userId });

    if (opts.filter === 'week') {
      qb.andWhere(`d.recorded_at >= date_trunc('week', now())`);
    } else if (opts.filter === 'month') {
      qb.andWhere(`d.recorded_at >= date_trunc('month', now())`);
    }

    if (opts.search && opts.search.trim().length > 0) {
      qb.andWhere(
        `to_tsvector('english', coalesce(d.title,'') || ' ' || d.content) @@ plainto_tsquery('english', :q)`,
        { q: opts.search.trim() },
      );
    }

    qb.orderBy('d.recorded_at', 'DESC')
      .skip((opts.page - 1) * opts.limit)
      .take(opts.limit);

    const [rows, total] = await qb.getManyAndCount();
    return { rows, total };
  }
}
