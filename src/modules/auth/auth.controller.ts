import {
  Body,
  Controller,
  Delete,
  HttpCode,
  HttpStatus,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Request } from 'express';
import { AuthService } from './auth.service';
import { AuthRegisterDto } from './dto/auth-register.dto';
import { AuthLoginDto } from './dto/auth-login.dto';
import { AuthGoogleDto } from './dto/auth-google.dto';
import { AuthAppleDto } from './dto/auth-apple.dto';
import { AuthRefreshDto } from './dto/auth-refresh.dto';
import { AuthResponseDomain } from './domain/auth-response';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { JwtRefreshAuthGuard } from './guards/jwt-refresh-auth.guard';
import { JwtRefreshValidated } from './strategies/jwt-refresh.strategy';
import { JwtUser } from '../../common/types/request.types';

@ApiTags('auth')
@Controller({ path: 'auth', version: '1' })
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  @ApiOperation({ summary: 'Email registration' })
  register(@Body() dto: AuthRegisterDto): Promise<AuthResponseDomain> {
    return this.authService.register(dto);
  }

  @Post('login/email')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Email + password login' })
  loginEmail(@Body() dto: AuthLoginDto): Promise<AuthResponseDomain> {
    return this.authService.loginEmail(dto);
  }

  @Post('google')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Exchange Google ID token for Lumen session' })
  loginGoogle(@Body() dto: AuthGoogleDto): Promise<AuthResponseDomain> {
    return this.authService.loginGoogle(dto);
  }

  @Post('apple')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Exchange Apple identity token for Lumen session' })
  loginApple(@Body() dto: AuthAppleDto): Promise<AuthResponseDomain> {
    return this.authService.loginApple(dto);
  }

  @Post('refresh')
  @UseGuards(JwtRefreshAuthGuard)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Rotate refresh token and issue fresh pair' })
  refresh(
    @Body() _dto: AuthRefreshDto,
    @Req() req: Request & { user: JwtRefreshValidated },
  ): Promise<AuthResponseDomain> {
    return this.authService.refresh(req.user.refreshToken, req.user);
  }

  @Post('logout')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Invalidate a refresh token' })
  async logout(
    @Body() dto: AuthRefreshDto,
    @Req() req: Request & { user: JwtUser },
  ): Promise<void> {
    await this.authService.logout(req.user.id, dto.refreshToken);
  }

  @Delete('me')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Soft-delete current user account' })
  async deleteMe(@Req() req: Request & { user: JwtUser }): Promise<void> {
    await this.authService.softDeleteMe(req.user.id);
  }
}
