import { ApiProperty } from '@nestjs/swagger';
import { IsString } from 'class-validator';

export class AuthGoogleDto {
  @ApiProperty({ description: 'Firebase ID token or Google ID token' })
  @IsString()
  idToken!: string;
}
