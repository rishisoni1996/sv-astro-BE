import { ApiProperty } from '@nestjs/swagger';
import { Expose } from 'class-transformer';
import { UserDomain } from '../../users/domain/user';

export class AuthResponseDomain {
  @ApiProperty() @Expose() accessToken!: string;
  @ApiProperty() @Expose() refreshToken!: string;
  @ApiProperty({ description: 'Access-token expiry (unix ms)' })
  @Expose()
  tokenExpires!: number;
  @ApiProperty({ type: () => UserDomain }) @Expose() user!: UserDomain;
}
