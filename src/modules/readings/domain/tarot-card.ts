import { ApiProperty } from '@nestjs/swagger';
import { Expose } from 'class-transformer';

export class TarotCardDomain {
  @ApiProperty() @Expose() id!: string;
  @ApiProperty() @Expose() numeral!: string;
  @ApiProperty() @Expose() name!: string;
  @ApiProperty({ type: [String] }) @Expose() keywords!: string[];
  @ApiProperty() @Expose() whatShows!: string;
  @ApiProperty() @Expose() appliesToToday!: string;
  @ApiProperty() @Expose() questionToCarry!: string;
  @ApiProperty() @Expose() deckName!: string;
}
