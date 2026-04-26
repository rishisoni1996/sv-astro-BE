import { ApiProperty } from '@nestjs/swagger';
import { Expose } from 'class-transformer';

export class DailyGuidanceDomain {
  @ApiProperty() @Expose() date!: string;
  @ApiProperty() @Expose() dateBadge!: string;
  @ApiProperty() @Expose() greeting!: string;
  @ApiProperty() @Expose() headline!: string;
  @ApiProperty() @Expose() subtext!: string;
}
