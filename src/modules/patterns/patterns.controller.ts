import { Controller, Get, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Request } from 'express';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { JwtUser } from '../../common/types/request.types';
import { SymbolDomain } from '../interpretations/domain/symbol';
import { PatternsService } from './patterns.service';
import { PatternsDomain } from './domain/patterns';

@ApiTags('patterns')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'patterns', version: '1' })
export class PatternsController {
  constructor(private readonly service: PatternsService) {}

  @Get()
  @ApiOperation({ summary: "Current week's patterns (triggers regeneration if stale)" })
  current(@Req() req: Request & { user: JwtUser }): Promise<PatternsDomain> {
    return this.service.getCurrentWeek(req.user.id);
  }

  @Get('symbols')
  @ApiOperation({ summary: 'All-time top symbols' })
  symbols(@Req() req: Request & { user: JwtUser }): Promise<SymbolDomain[]> {
    return this.service.getAllTimeSymbols(req.user.id);
  }
}
