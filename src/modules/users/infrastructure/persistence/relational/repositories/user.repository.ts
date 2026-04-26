import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserEntity } from '../entities/user.entity';
import { AuthProvider } from '../../../../users.enums';

@Injectable()
export class UserRepository {
  constructor(
    @InjectRepository(UserEntity)
    private readonly repo: Repository<UserEntity>,
  ) {}

  create(data: Partial<UserEntity>): UserEntity {
    return this.repo.create(data);
  }

  save(user: UserEntity): Promise<UserEntity> {
    return this.repo.save(user);
  }

  findById(id: string, withBirthChart = false): Promise<UserEntity | null> {
    return this.repo.findOne({
      where: { id },
      relations: withBirthChart ? ['birthChart'] : [],
    });
  }

  findByEmail(email: string): Promise<UserEntity | null> {
    return this.repo.findOne({ where: { email } });
  }

  findByProvider(provider: AuthProvider, providerId: string): Promise<UserEntity | null> {
    return this.repo.findOne({ where: { provider, providerId } });
  }

  async softDelete(id: string): Promise<void> {
    await this.repo.softDelete(id);
  }
}
