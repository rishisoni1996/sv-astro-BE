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
import { DailyGuidanceStatus } from '../../../../guidance.enums';

@Entity({ name: 'daily_guidance' })
@Index(['userId', 'guidanceDate'], { unique: true })
export class DailyGuidanceEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'user_id' })
  userId!: string;

  @ManyToOne(() => UserEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user?: UserEntity;

  @Column({ type: 'date', name: 'guidance_date' })
  guidanceDate!: string;

  @Column({ type: 'varchar', length: 100 })
  greeting!: string;

  @Column({ type: 'text' })
  headline!: string;

  @Column({ type: 'text' })
  subtext!: string;

  @Column({ type: 'varchar', length: 200, name: 'astro_context', nullable: true })
  astroContext!: string | null;

  @Column({
    type: 'enum',
    enum: DailyGuidanceStatus,
    default: DailyGuidanceStatus.DONE,
  })
  status!: DailyGuidanceStatus;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
