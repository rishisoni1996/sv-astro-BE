import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  OneToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { UserEntity } from './user.entity';

@Entity({ name: 'birth_charts' })
export class BirthChartEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', unique: true, name: 'user_id' })
  userId!: string;

  @OneToOne(() => UserEntity, (user) => user.birthChart, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user?: UserEntity;

  @Column({ type: 'varchar', length: 20, name: 'sun_sign' })
  sunSign!: string;

  @Column({ type: 'varchar', length: 20, name: 'moon_sign' })
  moonSign!: string;

  @Column({ type: 'varchar', length: 20, name: 'rising_sign' })
  risingSign!: string;

  @Column({ type: 'date', name: 'birth_date' })
  birthDate!: string;

  @Column({ type: 'time', nullable: true, name: 'birth_time' })
  birthTime!: string | null;

  @Column({ type: 'varchar', length: 200, nullable: true, name: 'birth_location' })
  birthLocation!: string | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
