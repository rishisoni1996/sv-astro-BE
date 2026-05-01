import { AppConfig } from './app-config.type';
import { AuthConfig } from './auth-config.type';
import { DatabaseConfig } from './database-config.type';
import { GoogleConfig } from './google-config.type';
import { AppleConfig } from './apple-config.type';
import { AiConfig } from './ai-config.type';
import { IapConfig } from './iap-config.type';

export type AllConfigType = {
  app: AppConfig;
  auth: AuthConfig;
  database: DatabaseConfig;
  google: GoogleConfig;
  apple: AppleConfig;
  ai: AiConfig;
  iap: IapConfig;
};
