import {
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Request } from 'express';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { JwtUser } from '../../common/types/request.types';
import { ReadingsService } from './readings.service';
import { ReadingDomain } from './domain/reading';

@ApiTags('readings')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'readings', version: '1' })
export class ReadingsController {
  constructor(private readonly service: ReadingsService) {}

  @Get('daily')
  @ApiOperation({ summary: "Today's deterministic tarot pull" })
  daily(@Req() req: Request & { user: JwtUser }): Promise<ReadingDomain> {
    return this.service.getDaily(req.user.id);
  }

  @Post('pull')
  @ApiOperation({ summary: 'Pull a random card (non-daily)' })
  pull(@Req() req: Request & { user: JwtUser }): Promise<ReadingDomain> {
    return this.service.pull(req.user.id);
  }

  @Get()
  @ApiOperation({ summary: 'List saved readings' })
  list(@Req() req: Request & { user: JwtUser }): Promise<ReadingDomain[]> {
    return this.service.listSaved(req.user.id);
  }

  @Patch(':id/save')
  @ApiOperation({ summary: 'Mark a reading as saved' })
  save(
    @Req() req: Request & { user: JwtUser },
    @Param('id', new ParseUUIDPipe()) id: string,
  ): Promise<ReadingDomain> {
    return this.service.save(req.user.id, id);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a reading' })
  async delete(
    @Req() req: Request & { user: JwtUser },
    @Param('id', new ParseUUIDPipe()) id: string,
  ): Promise<void> {
    await this.service.delete(req.user.id, id);
  }
}
