import { Column, Entity, Index, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'tarot_cards' })
export class TarotCardEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'varchar', length: 10 })
  numeral!: string;

  @Column({ type: 'varchar', length: 100 })
  name!: string;

  @Column({ type: 'varchar', length: 50, array: true })
  keywords!: string[];

  @Column({ type: 'text', name: 'what_shows' })
  whatShows!: string;

  @Column({ type: 'text', name: 'applies_today' })
  appliesToday!: string;

  @Column({ type: 'text' })
  question!: string;

  @Column({ type: 'varchar', length: 100, name: 'deck_name' })
  deckName!: string;

  @Index({ unique: true })
  @Column({ type: 'smallint', name: 'sort_order' })
  sortOrder!: number;
}
