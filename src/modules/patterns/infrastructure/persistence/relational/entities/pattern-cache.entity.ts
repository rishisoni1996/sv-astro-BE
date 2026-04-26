import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { UserEntity } from '../../../../../users/infrastructure/persistence/relational/entities/user.entity';
import { PatternCacheStatus } from '../../../../patterns.enums';

export interface CachedSymbol {
  emoji: string;
  name: string;
  count: number;
  lastSeenLabel: string;
}

export interface CachedTheme {
  label: string;
  percent: number;
}

@Entity({ name: 'pattern_caches' })
@Index(['userId', 'weekStart'], { unique: true })
export class PatternCacheEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'user_id' })
  userId!: string;

  @ManyToOne(() => UserEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user?: UserEntity;

  @Column({ type: 'date', name: 'week_start' })
  weekStart!: string;

  @Column({ type: 'jsonb', name: 'symbols_json', default: () => "'[]'::jsonb" })
  symbolsJson!: CachedSymbol[];

  @Column({ type: 'jsonb', name: 'themes_json', default: () => "'[]'::jsonb" })
  themesJson!: CachedTheme[];

  @Column({ type: 'text', nullable: true })
  summary!: string | null;

  @Column({ type: 'enum', enum: PatternCacheStatus, default: PatternCacheStatus.PENDING })
  status!: PatternCacheStatus;

  @Column({ type: 'timestamptz', name: 'generated_at', nullable: true })
  generatedAt!: Date | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
