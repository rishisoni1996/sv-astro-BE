import { registerAs } from '@nestjs/config';
import { IsOptional, IsString } from 'class-validator';
import validateConfig from '../utils/validate-config';
import { IapConfig } from './iap-config.type';

class EnvironmentVariablesValidator {
  @IsString()
  @IsOptional()
  APPLE_IAP_SHARED_SECRET?: string;

  @IsString()
  @IsOptional()
  GOOGLE_PLAY_SERVICE_ACCOUNT_JSON?: string;

  @IsString()
  @IsOptional()
  GOOGLE_PLAY_PACKAGE_NAME?: string;
}

export default registerAs<IapConfig>('iap', () => {
  validateConfig(process.env, EnvironmentVariablesValidator);

  return {
    appleSharedSecret: process.env.APPLE_IAP_SHARED_SECRET,
    googlePlayServiceAccountJson: process.env.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON,
    googlePlayPackageName: process.env.GOOGLE_PLAY_PACKAGE_NAME,
  };
});
