import { ApiProperty } from '@nestjs/swagger';
import { Expose, Type } from 'class-transformer';
import { DreamDomain } from './dream';

export class DreamsPageDomain {
  @ApiProperty({ type: [DreamDomain] })
  @Expose()
  @Type(() => DreamDomain)
  data!: DreamDomain[];

  @ApiProperty() @Expose() total!: number;
  @ApiProperty() @Expose() page!: number;
  @ApiProperty() @Expose() limit!: number;
}
