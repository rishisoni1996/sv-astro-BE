import { registerAs } from '@nestjs/config';
import { IsOptional, IsString } from 'class-validator';
import validateConfig from '../utils/validate-config';
import { AppleConfig } from './apple-config.type';

class EnvironmentVariablesValidator {
  @IsString()
  @IsOptional()
  APPLE_BUNDLE_ID?: string;
}

export default registerAs<AppleConfig>('apple', () => {
  validateConfig(process.env, EnvironmentVariablesValidator);

  return {
    bundleId: process.env.APPLE_BUNDLE_ID,
  };
});
