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
import { SignPositionEnum } from '../../../../guidance.enums';

@Entity({ name: 'sign_reveals' })
@Index(['userId', 'position'], { unique: true })
export class SignRevealEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'user_id' })
  userId!: string;

  @ManyToOne(() => UserEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user?: UserEntity;

  @Column({ type: 'enum', enum: SignPositionEnum })
  position!: SignPositionEnum;

  @Column({ type: 'varchar', length: 30, name: 'sign_name' })
  signName!: string;

  @Column({ type: 'text' })
  description!: string;

  @CreateDateColumn({ name: 'generated_at', type: 'timestamptz' })
  generatedAt!: Date;
}
