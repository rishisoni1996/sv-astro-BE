import { ApiProperty } from '@nestjs/swagger';
import { Expose, Type } from 'class-transformer';
import { SymbolDomain } from './symbol';

export class InterpretationDomain {
  @ApiProperty() @Expose() id!: string;
  @ApiProperty() @Expose() dreamId!: string;
  @ApiProperty() @Expose() status!: string;
  @ApiProperty({ nullable: true }) @Expose() coreMeaning!: string | null;
  @ApiProperty({ nullable: true }) @Expose() whatReveals!: string | null;
  @ApiProperty({ nullable: true }) @Expose() guidance!: string | null;

  @ApiProperty({ type: [SymbolDomain] })
  @Expose()
  @Type(() => SymbolDomain)
  symbols!: SymbolDomain[];

  @ApiProperty() @Expose() isPremiumLocked!: boolean;
}
