import { ApiProperty } from '@nestjs/swagger';
import { IsInt, IsObject, Max, Min } from 'class-validator';

export class SubmitQuizStepDto {
  @ApiProperty({ minimum: 1, maximum: 8 })
  @IsInt()
  @Min(1)
  @Max(8)
  step!: number;

  @ApiProperty({ type: 'object', additionalProperties: true })
  @IsObject()
  answer!: Record<string, unknown>;
}
