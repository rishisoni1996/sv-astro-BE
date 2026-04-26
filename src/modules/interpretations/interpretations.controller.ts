import {
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Request } from 'express';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { JwtUser } from '../../common/types/request.types';
import { InterpretationsService } from './interpretations.service';
import { InterpretationDomain } from './domain/interpretation';

@ApiTags('interpretations')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'dreams/:dreamId/interpretation', version: '1' })
export class InterpretationsController {
  constructor(private readonly service: InterpretationsService) {}

  @Post()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Generate (or return existing) dream interpretation' })
  trigger(
    @Req() req: Request & { user: JwtUser },
    @Param('dreamId', new ParseUUIDPipe()) dreamId: string,
  ): Promise<InterpretationDomain> {
    return this.service.trigger(req.user.id, dreamId);
  }

  @Get()
  @ApiOperation({ summary: 'Fetch dream interpretation' })
  get(
    @Req() req: Request & { user: JwtUser },
    @Param('dreamId', new ParseUUIDPipe()) dreamId: string,
  ): Promise<InterpretationDomain> {
    return this.service.get(req.user.id, dreamId);
  }
}
