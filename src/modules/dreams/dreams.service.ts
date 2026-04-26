import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { AiService } from '../../ai/ai.service';
import { normalizePagination, toPaginated } from '../../utils/pagination';
import { DreamEntity } from './infrastructure/persistence/relational/entities/dream.entity';
import { DreamRepository } from './infrastructure/persistence/relational/repositories/dream.repository';
import { DreamMapper } from './infrastructure/persistence/relational/mappers/dream.mapper';
import { DreamDomain } from './domain/dream';
import { DreamsPageDomain } from './domain/dreams-page';
import { CreateDreamDto } from './dto/create-dream.dto';
import { UpdateDreamDto } from './dto/update-dream.dto';
import { ListDreamsQueryDto } from './dto/list-dreams-query.dto';
import { DreamInterpretationEntity } from '../interpretations/infrastructure/persistence/relational/entities/dream-interpretation.entity';
import { InterpretationStatus } from '../interpretations/interpretations.enums';

@Injectable()
export class DreamsService {
  constructor(
    private readonly dreamRepo: DreamRepository,
    private readonly aiService: AiService,
    @InjectRepository(DreamInterpretationEntity)
    private readonly interpretationRepo: Repository<DreamInterpretationEntity>,
  ) {}

  async create(userId: string, dto: CreateDreamDto): Promise<DreamDomain> {
    const entity = this.dreamRepo.create({
      userId,
      title: dto.title ?? null,
      content: dto.content,
      typeTags: dto.typeTags,
      emotionTags: dto.emotionTags,
      recordedAt: dto.recordedAt ? new Date(dto.recordedAt) : new Date(),
    });
    const saved = await this.dreamRepo.save(entity);

    if (!saved.title) {
      void this.attemptTitleExtraction(saved);
    }
    return DreamMapper.toDomain(saved, false);
  }

  async list(userId: string, query: ListDreamsQueryDto): Promise<DreamsPageDomain> {
    const { page, limit } = normalizePagination(query.page, query.limit);
    const { rows, total } = await this.dreamRepo.list({
      userId,
      filter: query.filter,
      search: query.search,
      page,
      limit,
    });

    const ids = rows.map((r) => r.id);
    const interpreted = new Set<string>();
    if (ids.length > 0) {
      const interps = await this.interpretationRepo.find({
        where: { dreamId: In(ids), status: InterpretationStatus.DONE },
        select: { dreamId: true },
      });
      for (const i of interps) interpreted.add(i.dreamId);
    }

    const data = rows.map((r) => DreamMapper.toDomain(r, interpreted.has(r.id)));
    const page_ = toPaginated(data, total, { page, limit });
    const result = new DreamsPageDomain();
    result.data = page_.data;
    result.total = page_.total;
    result.page = page_.page;
    result.limit = page_.limit;
    return result;
  }

  async findOne(userId: string, id: string): Promise<DreamDomain> {
    const dream = await this.dreamRepo.findByIdForUser(id, userId);
    if (!dream) throw new NotFoundException('Dream not found');
    const interp = await this.interpretationRepo.findOne({ where: { dreamId: dream.id } });
    return DreamMapper.toDomain(dream, interp?.status === InterpretationStatus.DONE);
  }

  async update(userId: string, id: string, dto: UpdateDreamDto): Promise<DreamDomain> {
    const dream = await this.dreamRepo.findByIdForUser(id, userId);
    if (!dream) throw new NotFoundException('Dream not found');
    if (dto.title !== undefined) dream.title = dto.title;
    if (dto.content !== undefined) dream.content = dto.content;
    if (dto.typeTags !== undefined) dream.typeTags = dto.typeTags;
    if (dto.emotionTags !== undefined) dream.emotionTags = dto.emotionTags;
    if (dto.recordedAt !== undefined) dream.recordedAt = new Date(dto.recordedAt);
    const saved = await this.dreamRepo.save(dream);
    const interp = await this.interpretationRepo.findOne({ where: { dreamId: saved.id } });
    return DreamMapper.toDomain(saved, interp?.status === InterpretationStatus.DONE);
  }

  async remove(userId: string, id: string): Promise<void> {
    const dream = await this.dreamRepo.findByIdForUser(id, userId);
    if (!dream) throw new NotFoundException('Dream not found');
    await this.dreamRepo.softDelete(id);
  }

  private async attemptTitleExtraction(dream: DreamEntity): Promise<void> {
    try {
      const title = await this.aiService.extractTitle(dream.content);
      if (title) {
        dream.title = title;
        await this.dreamRepo.save(dream);
      }
    } catch {
      // non-fatal
    }
  }
}
