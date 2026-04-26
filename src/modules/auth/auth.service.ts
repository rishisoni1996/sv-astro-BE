import {
  BadRequestException,
  Injectable,
  Logger,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { OAuth2Client } from 'google-auth-library';
import * as jwt from 'jsonwebtoken';
import * as jwksClient from 'jwks-rsa';
import { randomUUID } from 'crypto';
import { AllConfigType } from '../../config/config.type';
import { UserRepository } from '../users/infrastructure/persistence/relational/repositories/user.repository';
import { UserEntity } from '../users/infrastructure/persistence/relational/entities/user.entity';
import { AuthProvider, UserRole } from '../users/users.enums';
import { UsersService } from '../users/users.service';
import { AuthRegisterDto } from './dto/auth-register.dto';
import { AuthLoginDto } from './dto/auth-login.dto';
import { AuthGoogleDto } from './dto/auth-google.dto';
import { AuthAppleDto } from './dto/auth-apple.dto';
import { AuthTokenRepository } from './infrastructure/persistence/relational/repositories/auth-token.repository';
import { AuthResponseDomain } from './domain/auth-response';
import { JwtAccessPayload, JwtRefreshPayload } from './strategies/types/jwt-payload.type';

const BCRYPT_ROUNDS = 10;

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);
  private readonly googleClient: OAuth2Client;
  private readonly appleJwks: jwksClient.JwksClient;

  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService<AllConfigType>,
    private readonly userRepo: UserRepository,
    private readonly tokenRepo: AuthTokenRepository,
    private readonly usersService: UsersService,
  ) {
    this.googleClient = new OAuth2Client(
      this.configService.get('google.clientId', { infer: true }),
    );
    this.appleJwks = jwksClient({
      jwksUri: 'https://appleid.apple.com/auth/keys',
      cache: true,
      cacheMaxAge: 60 * 60 * 1000,
    });
  }

  async register(dto: AuthRegisterDto): Promise<AuthResponseDomain> {
    const existing = await this.userRepo.findByEmail(dto.email);
    if (existing) throw new BadRequestException('Email already registered');

    const hash = dto.password ? await bcrypt.hash(dto.password, BCRYPT_ROUNDS) : null;
    const user = this.userRepo.create({
      email: dto.email,
      name: dto.name,
      initials: buildInitials(dto.name),
      provider: AuthProvider.EMAIL,
      providerId: null,
      role: UserRole.USER,
      hash,
    });
    const saved = await this.userRepo.save(user);
    return this.buildAuthResponse(saved);
  }

  async loginEmail(dto: AuthLoginDto): Promise<AuthResponseDomain> {
    const user = await this.userRepo.findByEmail(dto.email);
    if (!user?.hash) throw new UnauthorizedException('Invalid credentials');
    const ok = await bcrypt.compare(dto.password, user.hash);
    if (!ok) throw new UnauthorizedException('Invalid credentials');
    if (!user.isActive) throw new UnauthorizedException('Account disabled');
    return this.buildAuthResponse(user);
  }

  async loginGoogle(dto: AuthGoogleDto): Promise<AuthResponseDomain> {
    const clientId = this.configService.get('google.clientId', { infer: true });
    if (!clientId) throw new UnauthorizedException('Google auth not configured');
    const ticket = await this.googleClient.verifyIdToken({
      idToken: dto.idToken,
      audience: clientId,
    });
    const payload = ticket.getPayload();
    if (!payload?.sub) throw new UnauthorizedException('Invalid Google token');

    const existing = await this.userRepo.findByProvider(AuthProvider.GOOGLE, payload.sub);
    const user =
      existing ??
      (await this.createSocialUser(
        AuthProvider.GOOGLE,
        payload.sub,
        payload.email ?? null,
        payload.name ?? payload.email ?? 'User',
      ));
    return this.buildAuthResponse(user);
  }

  async loginApple(dto: AuthAppleDto): Promise<AuthResponseDomain> {
    const payload = await this.verifyAppleIdentityToken(dto.identityToken);
    const subject = payload.sub;
    if (!subject) throw new UnauthorizedException('Invalid Apple token');

    const existing = await this.userRepo.findByProvider(AuthProvider.APPLE, subject);
    const user =
      existing ??
      (await this.createSocialUser(
        AuthProvider.APPLE,
        subject,
        (payload.email as string | undefined) ?? null,
        dto.fullName ?? (payload.email as string | undefined) ?? 'User',
      ));
    return this.buildAuthResponse(user);
  }

  async refresh(refreshToken: string, payload: JwtRefreshPayload): Promise<AuthResponseDomain> {
    const user = await this.userRepo.findById(payload.sub);
    if (!user) throw new UnauthorizedException();

    const stored = await this.tokenRepo.findActiveByUser(user.id);
    const match = await Promise.all(
      stored.map(async (row) => ({
        row,
        match: await bcrypt.compare(refreshToken, row.tokenHash),
      })),
    );
    const hit = match.find((m) => m.match);
    if (!hit) throw new UnauthorizedException('Refresh token invalid');

    await this.tokenRepo.deleteById(hit.row.id);
    return this.buildAuthResponse(user);
  }

  async logout(userId: string, refreshToken: string): Promise<void> {
    const stored = await this.tokenRepo.findActiveByUser(userId);
    for (const row of stored) {
      if (await bcrypt.compare(refreshToken, row.tokenHash)) {
        await this.tokenRepo.deleteById(row.id);
      }
    }
  }

  async softDeleteMe(userId: string): Promise<void> {
    const user = await this.userRepo.findById(userId);
    if (!user) throw new NotFoundException();
    await this.tokenRepo.deleteAllForUser(userId);
    await this.userRepo.softDelete(userId);
  }

  private async buildAuthResponse(user: UserEntity): Promise<AuthResponseDomain> {
    const accessExpires = this.configService.getOrThrow('auth.expires', { infer: true });
    const refreshExpires = this.configService.getOrThrow('auth.refreshExpires', {
      infer: true,
    });

    const accessPayload: JwtAccessPayload = { sub: user.id, role: user.role };
    const sessionId = randomUUID();
    const refreshPayload: JwtRefreshPayload = { sub: user.id, sessionId };

    const accessToken = await this.jwtService.signAsync(accessPayload, {
      secret: this.configService.getOrThrow('auth.secret', { infer: true }),
      expiresIn: accessExpires,
    });
    const refreshToken = await this.jwtService.signAsync(refreshPayload, {
      secret: this.configService.getOrThrow('auth.refreshSecret', { infer: true }),
      expiresIn: refreshExpires,
    });

    const tokenHash = await bcrypt.hash(refreshToken, BCRYPT_ROUNDS);
    await this.tokenRepo.save(
      this.tokenRepo.create({
        userId: user.id,
        tokenHash,
        expiresAt: new Date(Date.now() + refreshExpires * 1000),
      }),
    );

    const tokenExpires = Date.now() + accessExpires * 1000;
    const userDomain = await this.usersService.toDomain(user);

    return { accessToken, refreshToken, tokenExpires, user: userDomain };
  }

  private async createSocialUser(
    provider: AuthProvider,
    providerId: string,
    email: string | null,
    displayName: string,
  ): Promise<UserEntity> {
    const user = this.userRepo.create({
      email,
      name: displayName,
      initials: buildInitials(displayName),
      provider,
      providerId,
      role: UserRole.USER,
      hash: null,
    });
    return this.userRepo.save(user);
  }

  private async verifyAppleIdentityToken(token: string): Promise<jwt.JwtPayload> {
    const decoded = jwt.decode(token, { complete: true });
    if (!decoded || typeof decoded === 'string') {
      throw new UnauthorizedException('Malformed Apple token');
    }
    const kid = (decoded.header as { kid?: string }).kid;
    if (!kid) throw new UnauthorizedException('Missing kid in Apple token');

    const key = await this.appleJwks.getSigningKey(kid);
    const publicKey = key.getPublicKey();
    const bundleId = this.configService.get('apple.bundleId', { infer: true });

    try {
      const verified = jwt.verify(token, publicKey, {
        algorithms: ['RS256'],
        issuer: 'https://appleid.apple.com',
        audience: bundleId || undefined,
      });
      if (typeof verified === 'string') {
        throw new UnauthorizedException('Malformed Apple token');
      }
      return verified;
    } catch (err) {
      this.logger.warn('Apple token verification failed', err as Error);
      throw new UnauthorizedException('Invalid Apple token');
    }
  }
}

function buildInitials(name: string): string {
  const parts = name.trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) return 'U';
  if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
  return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
}
