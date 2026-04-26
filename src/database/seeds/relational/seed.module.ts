import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DataSource, DataSourceOptions } from 'typeorm';
import appConfig from '../../../config/app.config';
import databaseConfig from '../../../config/database.config';
import { TypeOrmConfigService } from '../../typeorm-config.service';
import { SubscriptionPlanSeedModule } from './subscription-plan/subscription-plan-seed.module';
import { TarotCardSeedModule } from './tarot-card/tarot-card-seed.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [appConfig, databaseConfig],
      envFilePath: ['.env'],
    }),
    TypeOrmModule.forRootAsync({
      useClass: TypeOrmConfigService,
      dataSourceFactory: async (options?: DataSourceOptions) => {
        if (!options) throw new Error('Missing DataSource options');
        return new DataSource(options).initialize();
      },
      inject: [ConfigService],
    }),
    SubscriptionPlanSeedModule,
    TarotCardSeedModule,
  ],
})
export class SeedModule {}
