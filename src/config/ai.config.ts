import { registerAs } from '@nestjs/config';
import { IsOptional, IsString } from 'class-validator';
import validateConfig from '../utils/validate-config';
import { AiConfig } from './ai-config.type';

class EnvironmentVariablesValidator {
  @IsString()
  @IsOptional()
  GEMINI_API_KEY?: string;

  @IsString()
  @IsOptional()
  GEMINI_AI_MODEL?: string;

  @IsString()
  @IsOptional()
  GEMINI_BASEURL?: string;
}

export default registerAs<AiConfig>('ai', () => {
  validateConfig(process.env, EnvironmentVariablesValidator);

  return {
    apiKey: process.env.GEMINI_API_KEY,
    model: process.env.GEMINI_AI_MODEL || 'gemini-2.5-flash',
    baseUrl: process.env.GEMINI_BASEURL,
  };
});
