import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  OneToMany,
  OneToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { DreamEntity } from '../../../../../dreams/infrastructure/persistence/relational/entities/dream.entity';
import { InterpretationStatus } from '../../../../interpretations.enums';
import { DreamSymbolEntity } from './dream-symbol.entity';

@Entity({ name: 'dream_interpretations' })
export class DreamInterpretationEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Index({ unique: true })
  @Column({ type: 'uuid', name: 'dream_id' })
  dreamId!: string;

  @OneToOne(() => DreamEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'dream_id' })
  dream?: DreamEntity;

  @Column({ type: 'text', name: 'core_meaning', nullable: true })
  coreMeaning!: string | null;

  @Column({ type: 'text', name: 'what_reveals', nullable: true })
  whatReveals!: string | null;

  @Column({ type: 'text', nullable: true })
  guidance!: string | null;

  @Column({
    type: 'enum',
    enum: InterpretationStatus,
    default: InterpretationStatus.PENDING,
  })
  status!: InterpretationStatus;

  @OneToMany(() => DreamSymbolEntity, (s) => s.interpretation, { cascade: true })
  symbols?: DreamSymbolEntity[];

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
