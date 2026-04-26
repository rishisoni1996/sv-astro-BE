import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { InterpretationsController } from './interpretations.controller';
import { InterpretationsService } from './interpretations.service';
import { DreamInterpretationEntity } from './infrastructure/persistence/relational/entities/dream-interpretation.entity';
import { DreamSymbolEntity } from './infrastructure/persistence/relational/entities/dream-symbol.entity';
import { InterpretationRepository } from './infrastructure/persistence/relational/repositories/interpretation.repository';
import { DreamsModule } from '../dreams/dreams.module';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([DreamInterpretationEntity, DreamSymbolEntity]),
    DreamsModule,
    UsersModule,
  ],
  controllers: [InterpretationsController],
  providers: [InterpretationsService, InterpretationRepository],
  exports: [InterpretationsService, InterpretationRepository],
})
export class InterpretationsModule {}
