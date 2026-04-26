import {
  Body,
  Controller,
  Get,
  NotFoundException,
  Param,
  ParseIntPipe,
  Patch,
  Post,
  Put,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Request } from 'express';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { JwtUser } from '../../common/types/request.types';
import { UsersService } from './users.service';
import { UserDomain } from './domain/user';
import { BirthChartDomain } from './domain/birth-chart';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { UpsertBirthChartDto } from './dto/upsert-birth-chart.dto';
import { SubmitQuizStepDto } from './dto/submit-quiz-step.dto';

@ApiTags('users')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'users/me', version: '1' })
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  @ApiOperation({ summary: 'Current user profile' })
  findMe(@Req() req: Request & { user: JwtUser }): Promise<UserDomain> {
    return this.usersService.findMe(req.user.id);
  }

  @Patch()
  @ApiOperation({ summary: 'Update name / initials' })
  updateMe(
    @Req() req: Request & { user: JwtUser },
    @Body() dto: UpdateProfileDto,
  ): Promise<UserDomain> {
    return this.usersService.updateMe(req.user.id, dto);
  }

  @Get('birth-chart')
  @ApiOperation({ summary: 'Get birth chart' })
  async getBirthChart(@Req() req: Request & { user: JwtUser }): Promise<BirthChartDomain> {
    const bc = await this.usersService.getBirthChart(req.user.id);
    if (!bc) throw new NotFoundException('Birth chart not set');
    return bc;
  }

  @Put('birth-chart')
  @ApiOperation({ summary: 'Create or replace birth chart' })
  upsertBirthChart(
    @Req() req: Request & { user: JwtUser },
    @Body() dto: UpsertBirthChartDto,
  ): Promise<BirthChartDomain> {
    return this.usersService.upsertBirthChart(req.user.id, dto);
  }

  @Post('onboarding/:step')
  @ApiOperation({ summary: 'Submit quiz answer for a step' })
  async submitQuizStep(
    @Req() req: Request & { user: JwtUser },
    @Param('step', ParseIntPipe) step: number,
    @Body() dto: SubmitQuizStepDto,
  ): Promise<{ success: true }> {
    await this.usersService.submitQuizStep(req.user.id, step, dto.answer);
    return { success: true };
  }
}
