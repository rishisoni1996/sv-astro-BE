import { BirthChartDomain } from '../../../../domain/birth-chart';
import { BirthChartEntity } from '../entities/birth-chart.entity';

export class BirthChartMapper {
  static toDomain(entity: BirthChartEntity): BirthChartDomain {
    const d = new BirthChartDomain();
    d.sunSign = entity.sunSign;
    d.moonSign = entity.moonSign;
    d.risingSign = entity.risingSign;
    d.birthDate = entity.birthDate;
    d.birthTime = entity.birthTime;
    d.birthLocation = entity.birthLocation;
    return d;
  }
}
