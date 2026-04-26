import { Controller, Get, Post, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Request } from 'express';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { JwtUser } from '../../common/types/request.types';
import { GuidanceService } from './guidance.service';
import { DailyGuidanceDomain } from './domain/daily-guidance';
import { SignRevealDomain } from './domain/sign-reveal';

@ApiTags('guidance')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'guidance', version: '1' })
export class GuidanceController {
  constructor(private readonly service: GuidanceService) {}

  @Get('daily')
  @ApiOperation({ summary: "Today's personalized guidance" })
  daily(@Req() req: Request & { user: JwtUser }): Promise<DailyGuidanceDomain> {
    return this.service.getDaily(req.user.id);
  }

  @Get('sign-reveals')
  @ApiOperation({ summary: 'Sun/Moon/Rising descriptions' })
  signReveals(@Req() req: Request & { user: JwtUser }): Promise<SignRevealDomain[]> {
    return this.service.getSignReveals(req.user.id);
  }

  @Post('sign-reveals/regenerate')
  @ApiOperation({ summary: 'Force-regenerate sign reveals' })
  regenerate(@Req() req: Request & { user: JwtUser }): Promise<SignRevealDomain[]> {
    return this.service.regenerateSignReveals(req.user.id);
  }
}
