import { ApiProperty } from '@nestjs/swagger';
import { IsString } from 'class-validator';

export class AuthRefreshDto {
  @ApiProperty()
  @IsString()
  refreshToken!: string;
}
