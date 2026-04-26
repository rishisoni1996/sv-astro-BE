import { ApiProperty } from '@nestjs/swagger';
import { Expose } from 'class-transformer';

export class DreamDomain {
  @ApiProperty() @Expose() id!: string;
  @ApiProperty({ nullable: true }) @Expose() title!: string | null;
  @ApiProperty() @Expose() content!: string;
  @ApiProperty({ type: [String] }) @Expose() typeTags!: string[];
  @ApiProperty({ type: [String] }) @Expose() emotionTags!: string[];
  @ApiProperty() @Expose() recordedAt!: string;
  @ApiProperty() @Expose() dateNumber!: string;
  @ApiProperty() @Expose() dateDay!: string;
  @ApiProperty() @Expose() timestamp!: string;
  @ApiProperty() @Expose() hasInterpretation!: boolean;
}
