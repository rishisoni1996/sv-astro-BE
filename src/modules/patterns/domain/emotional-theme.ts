import { ApiProperty } from '@nestjs/swagger';
import { Expose } from 'class-transformer';

export class EmotionalThemeDomain {
  @ApiProperty() @Expose() label!: string;
  @ApiProperty() @Expose() percent!: number;
  @ApiProperty() @Expose() colorHex!: string;
}
