import { ApiProperty } from '@nestjs/swagger';
import { Expose, Type } from 'class-transformer';
import { TarotCardDomain } from './tarot-card';

export class ReadingDomain {
  @ApiProperty() @Expose() id!: string;

  @ApiProperty({ type: () => TarotCardDomain })
  @Expose()
  @Type(() => TarotCardDomain)
  card!: TarotCardDomain;

  @ApiProperty() @Expose() pulledAt!: string;
  @ApiProperty() @Expose() saved!: boolean;
}
