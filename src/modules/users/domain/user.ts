import { ApiProperty } from '@nestjs/swagger';
import { Expose } from 'class-transformer';
import { BirthChartDomain } from './birth-chart';

export class UserDomain {
  @ApiProperty() @Expose() id!: string;
  @ApiProperty() @Expose() name!: string;
  @ApiProperty() @Expose() initials!: string;
  @ApiProperty({ nullable: true }) @Expose() email!: string | null;
  @ApiProperty() @Expose() role!: string;
  @ApiProperty() @Expose() isPremium!: boolean;
  @ApiProperty() @Expose() dreamCount!: number;
  @ApiProperty() @Expose() memberSince!: string;
  @ApiProperty({ type: () => BirthChartDomain, required: false })
  @Expose()
  birthChart?: BirthChartDomain;
}
