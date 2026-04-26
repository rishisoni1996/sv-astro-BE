import { ApiProperty } from '@nestjs/swagger';
import { Expose } from 'class-transformer';

export class SymbolDomain {
  @ApiProperty() @Expose() id!: string;
  @ApiProperty() @Expose() emoji!: string;
  @ApiProperty() @Expose() name!: string;
  @ApiProperty() @Expose() occurrenceCount!: number;
  @ApiProperty() @Expose() lastSeenLabel!: string;
}
