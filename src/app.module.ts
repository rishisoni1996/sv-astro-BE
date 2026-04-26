import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DataSource, DataSourceOptions } from 'typeorm';

import appConfig from './config/app.config';
import authConfig from './config/auth.config';
import databaseConfig from './config/database.config';
import googleConfig from './config/google.config';
import appleConfig from './config/apple.config';
import openaiConfig from './config/openai.config';
import iapConfig from './config/iap.config';

import { TypeOrmConfigService } from './database/typeorm-config.service';
import { AiModule } from './ai/ai.module';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { DreamsModule } from './modules/dreams/dreams.module';
import { InterpretationsModule } from './modules/interpretations/interpretations.module';
import { PatternsModule } from './modules/patterns/patterns.module';
import { GuidanceModule } from './modules/guidance/guidance.module';
import { ReadingsModule } from './modules/readings/readings.module';
import { SubscriptionsModule } from './modules/subscriptions/subscriptions.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [
        appConfig,
        authConfig,
        databaseConfig,
        googleConfig,
        appleConfig,
        openaiConfig,
        iapConfig,
      ],
      envFilePath: ['.env'],
    }),
    TypeOrmModule.forRootAsync({
      useClass: TypeOrmConfigService,
      dataSourceFactory: async (options?: DataSourceOptions) => {
        if (!options) {
          throw new Error('Missing TypeORM data source options');
        }
        return new DataSource(options).initialize();
      },
      inject: [ConfigService],
    }),
    AiModule,
    AuthModule,
    UsersModule,
    DreamsModule,
    InterpretationsModule,
    PatternsModule,
    GuidanceModule,
    ReadingsModule,
    SubscriptionsModule,
  ],
})
export class AppModule {}
