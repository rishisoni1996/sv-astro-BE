import { Column, Entity, PrimaryColumn } from 'typeorm';

@Entity({ name: 'subscription_plans' })
export class SubscriptionPlanEntity {
  @PrimaryColumn({ type: 'varchar', length: 20 })
  id!: string;

  @Column({ type: 'varchar', length: 20 })
  title!: string;

  @Column({ type: 'decimal', precision: 6, scale: 2 })
  price!: string;

  @Column({ type: 'varchar', length: 5 })
  unit!: string;

  @Column({ type: 'varchar', length: 30, nullable: true })
  badge!: string | null;

  @Column({ type: 'smallint', name: 'sort_order', default: 0 })
  sortOrder!: number;
}
