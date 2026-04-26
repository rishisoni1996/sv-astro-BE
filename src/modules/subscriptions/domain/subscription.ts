import { ApiProperty } from '@nestjs/swagger';
import { Expose } from 'class-transformer';

export class SubscriptionDomain {
  @ApiProperty() @Expose() planId!: string;
  @ApiProperty() @Expose() status!: string;
  @ApiProperty() @Expose() isPremium!: boolean;
  @ApiProperty({ nullable: true }) @Expose() trialEndsAt!: string | null;
  @ApiProperty({ nullable: true }) @Expose() expiresAt!: string | null;
  @ApiProperty() @Expose() planLabel!: string;
  @ApiProperty() @Expose() renewsLabel!: string;
}
