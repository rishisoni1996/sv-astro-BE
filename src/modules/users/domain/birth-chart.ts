import { ApiProperty } from '@nestjs/swagger';
import { Expose } from 'class-transformer';

export class BirthChartDomain {
  @ApiProperty() @Expose() sunSign!: string;
  @ApiProperty() @Expose() moonSign!: string;
  @ApiProperty({ nullable: true }) @Expose() risingSign!: string | null;
  @ApiProperty() @Expose() birthDate!: string;
  @ApiProperty({ nullable: true }) @Expose() birthTime!: string | null;
  @ApiProperty({ nullable: true }) @Expose() birthLocation!: string | null;
}
