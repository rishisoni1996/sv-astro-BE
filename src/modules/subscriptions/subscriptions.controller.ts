import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Request } from 'express';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { JwtUser } from '../../common/types/request.types';
import { SubscriptionsService } from './subscriptions.service';
import { SubscriptionDomain } from './domain/subscription';
import { SubscriptionPlanDomain } from './domain/plan';
import { ValidateIapDto } from './dto/validate-iap.dto';
import { RestorePurchasesDto } from './dto/restore-purchases.dto';

@ApiTags('subscriptions')
@Controller({ path: 'subscriptions', version: '1' })
export class SubscriptionsController {
  constructor(private readonly service: SubscriptionsService) {}

  @Get('plans')
  @ApiOperation({ summary: 'List all subscription plans (public)' })
  plans(): Promise<SubscriptionPlanDomain[]> {
    return this.service.listPlans();
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Current subscription status' })
  me(@Req() req: Request & { user: JwtUser }): Promise<SubscriptionDomain | null> {
    return this.service.me(req.user.id);
  }

  @Post('validate')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Validate IAP receipt and activate subscription' })
  validate(
    @Req() req: Request & { user: JwtUser },
    @Body() dto: ValidateIapDto,
  ): Promise<SubscriptionDomain> {
    return this.service.validate(req.user.id, dto);
  }

  @Post('restore')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Restore a previous purchase' })
  restore(
    @Req() req: Request & { user: JwtUser },
    @Body() dto: RestorePurchasesDto,
  ): Promise<SubscriptionDomain> {
    return this.service.restore(req.user.id, dto);
  }

  @Delete('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Cancel auto-renew' })
  async cancel(@Req() req: Request & { user: JwtUser }): Promise<void> {
    await this.service.cancel(req.user.id);
  }
}
