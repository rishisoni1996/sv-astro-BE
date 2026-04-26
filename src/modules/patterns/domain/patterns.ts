import { ApiProperty } from '@nestjs/swagger';
import { Expose, Type } from 'class-transformer';
import { SymbolDomain } from '../../interpretations/domain/symbol';
import { EmotionalThemeDomain } from './emotional-theme';

export class PatternsDomain {
  @ApiProperty() @Expose() weekStart!: string;

  @ApiProperty({ type: [SymbolDomain] })
  @Expose()
  @Type(() => SymbolDomain)
  recurringSymbols!: SymbolDomain[];

  @ApiProperty({ type: [EmotionalThemeDomain] })
  @Expose()
  @Type(() => EmotionalThemeDomain)
  themes!: EmotionalThemeDomain[];

  @ApiProperty({ nullable: true }) @Expose() weeklySummary!: string | null;
  @ApiProperty() @Expose() isSummaryLocked!: boolean;
}
