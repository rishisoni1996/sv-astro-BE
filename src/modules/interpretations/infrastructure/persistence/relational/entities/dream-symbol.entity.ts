import { Column, Entity, Index, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { DreamInterpretationEntity } from './dream-interpretation.entity';

@Entity({ name: 'dream_symbols' })
@Index(['interpretationId'])
export class DreamSymbolEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'interpretation_id' })
  interpretationId!: string;

  @ManyToOne(() => DreamInterpretationEntity, (i) => i.symbols, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'interpretation_id' })
  interpretation?: DreamInterpretationEntity;

  @Column({ type: 'varchar', length: 10 })
  emoji!: string;

  @Column({ type: 'varchar', length: 100 })
  name!: string;

  @Column({ type: 'smallint', name: 'occurrence_count', default: 1 })
  occurrenceCount!: number;

  @Column({ type: 'varchar', length: 50, name: 'last_seen_label', nullable: true })
  lastSeenLabel!: string | null;

  @Column({ type: 'smallint', name: 'sort_order', default: 0 })
  sortOrder!: number;
}
