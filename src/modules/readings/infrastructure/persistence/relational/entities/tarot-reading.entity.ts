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
import { TarotCardEntity } from './tarot-card.entity';

@Entity({ name: 'tarot_readings' })
@Index(['userId', 'dailyDate'], { unique: true, where: '"daily_date" IS NOT NULL' })
export class TarotReadingEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'user_id' })
  userId!: string;

  @ManyToOne(() => UserEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user?: UserEntity;

  @Column({ type: 'uuid', name: 'card_id' })
  cardId!: string;

  @ManyToOne(() => TarotCardEntity, { onDelete: 'CASCADE', eager: true })
  @JoinColumn({ name: 'card_id' })
  card?: TarotCardEntity;

  @CreateDateColumn({ name: 'pulled_at', type: 'timestamptz' })
  pulledAt!: Date;

  @Column({ type: 'boolean', default: false })
  saved!: boolean;

  @Column({ type: 'date', name: 'daily_date', nullable: true })
  dailyDate!: string | null;
}
