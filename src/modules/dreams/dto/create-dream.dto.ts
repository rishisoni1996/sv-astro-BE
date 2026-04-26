import { ApiProperty } from '@nestjs/swagger';
import { IsArray, IsDateString, IsIn, IsOptional, IsString, MinLength } from 'class-validator';
import { DREAM_EMOTION_TAGS, DREAM_TYPE_TAGS } from '../dreams.enums';

export class CreateDreamDto {
  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  title?: string;

  @ApiProperty()
  @IsString()
  @MinLength(1)
  content!: string;

  @ApiProperty({ enum: DREAM_TYPE_TAGS, isArray: true })
  @IsArray()
  @IsString({ each: true })
  @IsIn(DREAM_TYPE_TAGS as unknown as string[], { each: true })
  typeTags!: string[];

  @ApiProperty({ enum: DREAM_EMOTION_TAGS, isArray: true })
  @IsArray()
  @IsString({ each: true })
  @IsIn(DREAM_EMOTION_TAGS as unknown as string[], { each: true })
  emotionTags!: string[];

  @ApiProperty({ required: false })
  @IsOptional()
  @IsDateString()
  recordedAt?: string;
}
