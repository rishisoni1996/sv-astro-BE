import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Request } from 'express';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { JwtUser } from '../../common/types/request.types';
import { DreamsService } from './dreams.service';
import { CreateDreamDto } from './dto/create-dream.dto';
import { UpdateDreamDto } from './dto/update-dream.dto';
import { ListDreamsQueryDto } from './dto/list-dreams-query.dto';
import { DreamDomain } from './domain/dream';
import { DreamsPageDomain } from './domain/dreams-page';

@ApiTags('dreams')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'dreams', version: '1' })
export class DreamsController {
  constructor(private readonly dreamsService: DreamsService) {}

  @Post()
  @ApiOperation({ summary: 'Create a dream' })
  create(
    @Req() req: Request & { user: JwtUser },
    @Body() dto: CreateDreamDto,
  ): Promise<DreamDomain> {
    return this.dreamsService.create(req.user.id, dto);
  }

  @Get()
  @ApiOperation({ summary: 'List dreams (paginated)' })
  list(
    @Req() req: Request & { user: JwtUser },
    @Query() query: ListDreamsQueryDto,
  ): Promise<DreamsPageDomain> {
    return this.dreamsService.list(req.user.id, query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a single dream' })
  findOne(
    @Req() req: Request & { user: JwtUser },
    @Param('id', new ParseUUIDPipe()) id: string,
  ): Promise<DreamDomain> {
    return this.dreamsService.findOne(req.user.id, id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a dream' })
  update(
    @Req() req: Request & { user: JwtUser },
    @Param('id', new ParseUUIDPipe()) id: string,
    @Body() dto: UpdateDreamDto,
  ): Promise<DreamDomain> {
    return this.dreamsService.update(req.user.id, id, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Soft-delete a dream' })
  async remove(
    @Req() req: Request & { user: JwtUser },
    @Param('id', new ParseUUIDPipe()) id: string,
  ): Promise<void> {
    await this.dreamsService.remove(req.user.id, id);
  }
}
