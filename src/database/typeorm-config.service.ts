import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { TypeOrmModuleOptions, TypeOrmOptionsFactory } from '@nestjs/typeorm';
import { AllConfigType } from '../config/config.type';

@Injectable()
export class TypeOrmConfigService implements TypeOrmOptionsFactory {
  constructor(private configService: ConfigService<AllConfigType>) {}

  createTypeOrmOptions(): TypeOrmModuleOptions {
    return {
      type: this.configService.get('database.type', { infer: true }) as 'postgres',
      host: this.configService.get('database.host', { infer: true }) as string,
      port: this.configService.get('database.port', { infer: true }) as number,
      username: this.configService.get('database.username', { infer: true }) as string,
      password: this.configService.get('database.password', { infer: true }) as string,
      database: this.configService.get('database.name', { infer: true }) as string,
      synchronize: this.configService.get('database.synchronize', { infer: true }),
      autoLoadEntities: true,
      extra: {
        max: this.configService.get('database.maxConnections', { infer: true }),
      },
      ssl: this.configService.get('database.sslEnabled', { infer: true })
        ? {
            rejectUnauthorized: this.configService.get('database.rejectUnauthorized', {
              infer: true,
            }),
          }
        : undefined,
      logging: this.configService.get('app.nodeEnv', { infer: true }) === 'development',
    };
  }
}
