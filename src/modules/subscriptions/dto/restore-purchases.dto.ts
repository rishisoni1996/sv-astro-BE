import { ApiProperty } from '@nestjs/swagger';
import { IsIn, IsString } from 'class-validator';

export class RestorePurchasesDto {
  @ApiProperty({ enum: ['apple', 'google'] })
  @IsIn(['apple', 'google'])
  provider!: 'apple' | 'google';

  @ApiProperty()
  @IsString()
  receiptToken!: string;
}
