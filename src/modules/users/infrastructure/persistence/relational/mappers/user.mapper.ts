import { UserDomain } from '../../../../domain/user';
import { UserEntity } from '../entities/user.entity';
import { BirthChartMapper } from './birth-chart.mapper';
import { formatMemberSince } from '../../../../../../utils/date-format.util';

export interface UserMapperExtras {
  isPremium: boolean;
  dreamCount: number;
}

export class UserMapper {
  static toDomain(entity: UserEntity, extras: UserMapperExtras): UserDomain {
    const d = new UserDomain();
    d.id = entity.id;
    d.name = entity.name;
    d.initials = entity.initials;
    d.email = entity.email;
    d.role = entity.role;
    d.isPremium = extras.isPremium;
    d.dreamCount = extras.dreamCount;
    d.memberSince = formatMemberSince(entity.createdAt);
    if (entity.birthChart) {
      d.birthChart = BirthChartMapper.toDomain(entity.birthChart);
    }
    return d;
  }
}
