import { ApiProperty } from '@nestjs/swagger';
import { Expose } from 'class-transformer';

export class SubscriptionPlanDomain {
  @ApiProperty() @Expose() id!: string;
  @ApiProperty() @Expose() title!: string;
  @ApiProperty() @Expose() price!: string;
  @ApiProperty() @Expose() unit!: string;
  @ApiProperty({ nullable: true }) @Expose() badge!: string | null;
}
