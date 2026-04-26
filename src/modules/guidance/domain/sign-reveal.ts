import { ApiProperty } from '@nestjs/swagger';
import { Expose } from 'class-transformer';

export class SignRevealDomain {
  @ApiProperty({ enum: ['sun', 'moon', 'rising'] })
  @Expose()
  position!: 'sun' | 'moon' | 'rising';

  @ApiProperty() @Expose() signName!: string;
  @ApiProperty() @Expose() label!: string;
  @ApiProperty() @Expose() description!: string;
}
