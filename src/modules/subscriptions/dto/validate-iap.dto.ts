import { ApiProperty } from '@nestjs/swagger';
import { IsIn, IsString } from 'class-validator';
import { VALID_PLAN_IDS } from '../subscriptions.enums';

export class ValidateIapDto {
  @ApiProperty({ enum: ['apple', 'google', 'stripe'] })
  @IsIn(['apple', 'google', 'stripe'])
  provider!: 'apple' | 'google' | 'stripe';

  @ApiProperty()
  @IsString()
  receiptToken!: string;

  @ApiProperty({ enum: VALID_PLAN_IDS })
  @IsIn(VALID_PLAN_IDS as unknown as string[])
  planId!: string;
}
