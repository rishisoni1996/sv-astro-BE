import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsBoolean, IsOptional } from 'class-validator';

export class PullCardDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  daily?: boolean;
}
