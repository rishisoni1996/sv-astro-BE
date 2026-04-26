import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  OneToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { UserEntity } from '../../../../../users/infrastructure/persistence/relational/entities/user.entity';
import { SubscriptionProvider, SubscriptionStatus } from '../../../../subscriptions.enums';
import { SubscriptionPlanEntity } from './subscription-plan.entity';

@Entity({ name: 'user_subscriptions' })
export class UserSubscriptionEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Index({ unique: true })
  @Column({ type: 'uuid', name: 'user_id' })
  userId!: string;

  @OneToOne(() => UserEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user?: UserEntity;

  @Column({ type: 'varchar', length: 20, name: 'plan_id' })
  planId!: string;

  @ManyToOne(() => SubscriptionPlanEntity)
  @JoinColumn({ name: 'plan_id' })
  plan?: SubscriptionPlanEntity;

  @Column({
    type: 'enum',
    enum: SubscriptionStatus,
    default: SubscriptionStatus.TRIAL,
  })
  status!: SubscriptionStatus;

  @Column({
    type: 'enum',
    enum: SubscriptionProvider,
    nullable: true,
  })
  provider!: SubscriptionProvider | null;

  @Column({ type: 'text', name: 'receipt_token', nullable: true })
  receiptToken!: string | null;

  @Column({ type: 'timestamptz', name: 'started_at', default: () => 'now()' })
  startedAt!: Date;

  @Column({ type: 'timestamptz', name: 'trial_ends_at', nullable: true })
  trialEndsAt!: Date | null;

  @Column({ type: 'timestamptz', name: 'expires_at', nullable: true })
  expiresAt!: Date | null;

  @Column({ type: 'boolean', name: 'auto_renew', default: true })
  autoRenew!: boolean;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
