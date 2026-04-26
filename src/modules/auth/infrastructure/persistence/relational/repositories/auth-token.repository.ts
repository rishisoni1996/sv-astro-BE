import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AuthTokenEntity } from '../entities/auth-token.entity';

@Injectable()
export class AuthTokenRepository {
  constructor(
    @InjectRepository(AuthTokenEntity)
    private readonly repo: Repository<AuthTokenEntity>,
  ) {}

  create(data: Partial<AuthTokenEntity>): AuthTokenEntity {
    return this.repo.create(data);
  }

  save(token: AuthTokenEntity): Promise<AuthTokenEntity> {
    return this.repo.save(token);
  }

  findActiveByUser(userId: string): Promise<AuthTokenEntity[]> {
    return this.repo.find({ where: { userId } });
  }

  async deleteById(id: string): Promise<void> {
    await this.repo.delete(id);
  }

  async deleteAllForUser(userId: string): Promise<void> {
    await this.repo.delete({ userId });
  }
}
