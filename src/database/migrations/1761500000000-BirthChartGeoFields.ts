import { MigrationInterface, QueryRunner } from 'typeorm';

export class BirthChartGeoFields1761500000000 implements MigrationInterface {
  name = 'BirthChartGeoFields1761500000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "birth_charts" ALTER COLUMN "rising_sign" DROP NOT NULL;`);
    await queryRunner.query(
      `ALTER TABLE "birth_charts" ADD COLUMN "birth_latitude" numeric(9,6);`,
    );
    await queryRunner.query(
      `ALTER TABLE "birth_charts" ADD COLUMN "birth_longitude" numeric(9,6);`,
    );
    await queryRunner.query(
      `ALTER TABLE "birth_charts" ADD COLUMN "birth_timezone" varchar(64);`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "birth_charts" DROP COLUMN "birth_timezone";`);
    await queryRunner.query(`ALTER TABLE "birth_charts" DROP COLUMN "birth_longitude";`);
    await queryRunner.query(`ALTER TABLE "birth_charts" DROP COLUMN "birth_latitude";`);
    await queryRunner.query(
      `ALTER TABLE "birth_charts" ALTER COLUMN "rising_sign" SET NOT NULL;`,
    );
  }
}
