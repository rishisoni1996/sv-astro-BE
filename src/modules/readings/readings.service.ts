import { Injectable, InternalServerErrorException, NotFoundException } from '@nestjs/common';
import { sha256Mod } from '../../utils/deterministic-hash.util';
import { ReadingsRepository } from './infrastructure/persistence/relational/repositories/readings.repository';
import { ReadingMapper } from './infrastructure/persistence/relational/mappers/tarot.mapper';
import { ReadingDomain } from './domain/reading';

const TAROT_COUNT = 22;

@Injectable()
export class ReadingsService {
  constructor(private readonly repo: ReadingsRepository) {}

  async getDaily(userId: string): Promise<ReadingDomain> {
    const today = new Date().toISOString().slice(0, 10);
    const existing = await this.repo.findDailyReading(userId, today);
    if (existing) {
      const refreshed = await this.repo.findReadingForUser(existing.id, userId);
      if (!refreshed) throw new InternalServerErrorException();
      return ReadingMapper.toDomain(refreshed);
    }

    const index = sha256Mod(`${userId}:${today}`, TAROT_COUNT);
    const card = await this.repo.findCardBySortOrder(index);
    if (!card) throw new InternalServerErrorException('Tarot deck not seeded');

    const reading = this.repo.createReading({
      userId,
      cardId: card.id,
      saved: false,
      dailyDate: today,
    });
    const saved = await this.repo.saveReading(reading);
    return this.loadReadingOrThrow(saved.id, userId);
  }

  async pull(userId: string): Promise<ReadingDomain> {
    const card = await this.repo.findRandomCard();
    if (!card) throw new InternalServerErrorException('Tarot deck not seeded');
    const reading = this.repo.createReading({
      userId,
      cardId: card.id,
      saved: false,
    });
    const saved = await this.repo.saveReading(reading);
    return this.loadReadingOrThrow(saved.id, userId);
  }

  async listSaved(userId: string): Promise<ReadingDomain[]> {
    const rows = await this.repo.listSaved(userId);
    return rows.map((r) => ReadingMapper.toDomain(r));
  }

  async save(userId: string, id: string): Promise<ReadingDomain> {
    const reading = await this.repo.findReadingForUser(id, userId);
    if (!reading) throw new NotFoundException('Reading not found');
    reading.saved = true;
    await this.repo.saveReading(reading);
    return this.loadReadingOrThrow(id, userId);
  }

  async delete(userId: string, id: string): Promise<void> {
    const reading = await this.repo.findReadingForUser(id, userId);
    if (!reading) throw new NotFoundException('Reading not found');
    await this.repo.deleteReading(id);
  }

  private async loadReadingOrThrow(id: string, userId: string): Promise<ReadingDomain> {
    const row = await this.repo.findReadingForUser(id, userId);
    if (!row) throw new InternalServerErrorException('Reading vanished after save');
    return ReadingMapper.toDomain(row);
  }
}
