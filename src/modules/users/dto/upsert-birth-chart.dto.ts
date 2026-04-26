import { ApiProperty } from '@nestjs/swagger';
import { IsDateString, IsOptional, IsString } from 'class-validator';

export class UpsertBirthChartDto {
  @ApiProperty() @IsString() sunSign!: string;
  @ApiProperty() @IsString() moonSign!: string;
  @ApiProperty() @IsString() risingSign!: string;

  @ApiProperty({ example: '1995-03-14' })
  @IsDateString()
  birthDate!: string;

  @ApiProperty({ required: false, example: '04:32' })
  @IsOptional()
  @IsString()
  birthTime?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  birthLocation?: string;
}
