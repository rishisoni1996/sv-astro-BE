import { registerAs } from '@nestjs/config';
import { IsInt, IsString, Min } from 'class-validator';
import validateConfig from '../utils/validate-config';
import { AuthConfig } from './auth-config.type';

class EnvironmentVariablesValidator {
  @IsString()
  AUTH_JWT_SECRET!: string;

  @IsInt()
  @Min(0)
  AUTH_JWT_TOKEN_EXPIRES_IN!: number;

  @IsString()
  AUTH_REFRESH_SECRET!: string;

  @IsInt()
  @Min(0)
  AUTH_REFRESH_TOKEN_EXPIRES_IN!: number;
}

export default registerAs<AuthConfig>('auth', () => {
  validateConfig(process.env, EnvironmentVariablesValidator);

  return {
    secret: process.env.AUTH_JWT_SECRET as string,
    expires: parseInt(process.env.AUTH_JWT_TOKEN_EXPIRES_IN as string, 10),
    refreshSecret: process.env.AUTH_REFRESH_SECRET as string,
    refreshExpires: parseInt(process.env.AUTH_REFRESH_TOKEN_EXPIRES_IN as string, 10),
  };
});
