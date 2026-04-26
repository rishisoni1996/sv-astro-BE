import { MigrationInterface, QueryRunner } from 'typeorm';

export class InitialSchema1700000000000 implements MigrationInterface {
  name = 'InitialSchema1700000000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`CREATE EXTENSION IF NOT EXISTS "pgcrypto";`);

    // Enum types
    await queryRunner.query(
      `CREATE TYPE "users_provider_enum" AS ENUM ('email','google','apple');`,
    );
    await queryRunner.query(`CREATE TYPE "users_role_enum" AS ENUM ('user','admin');`);
    await queryRunner.query(
      `CREATE TYPE "interpretation_status_enum" AS ENUM ('pending','processing','done','failed');`,
    );
    await queryRunner.query(
      `CREATE TYPE "pattern_cache_status_enum" AS ENUM ('pending','done','failed');`,
    );
    await queryRunner.query(
      `CREATE TYPE "daily_guidance_status_enum" AS ENUM ('pending','done','failed');`,
    );
    await queryRunner.query(`CREATE TYPE "sign_position_enum" AS ENUM ('sun','moon','rising');`);
    await queryRunner.query(
      `CREATE TYPE "subscription_status_enum" AS ENUM ('trial','active','cancelled','expired');`,
    );
    await queryRunner.query(
      `CREATE TYPE "subscription_provider_enum" AS ENUM ('apple','google','stripe');`,
    );

    // users
    await queryRunner.query(`
      CREATE TABLE "users" (
        "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        "email" varchar(255),
        "name" varchar(100) NOT NULL,
        "initials" varchar(4) NOT NULL,
        "provider" "users_provider_enum" NOT NULL DEFAULT 'email',
        "provider_id" varchar(255),
        "role" "users_role_enum" NOT NULL DEFAULT 'user',
        "is_active" boolean NOT NULL DEFAULT true,
        "hash" varchar,
        "created_at" timestamptz NOT NULL DEFAULT now(),
        "updated_at" timestamptz NOT NULL DEFAULT now(),
        "deleted_at" timestamptz
      );
    `);
    await queryRunner.query(
      `CREATE UNIQUE INDEX "uq_users_email_active" ON "users" ("email") WHERE "deleted_at" IS NULL;`,
    );

    // auth_tokens
    await queryRunner.query(`
      CREATE TABLE "auth_tokens" (
        "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        "user_id" uuid NOT NULL REFERENCES "users"("id") ON DELETE CASCADE,
        "token_hash" varchar(500) NOT NULL,
        "expires_at" timestamptz NOT NULL,
        "created_at" timestamptz NOT NULL DEFAULT now()
      );
    `);
    await queryRunner.query(`CREATE INDEX "idx_auth_tokens_user" ON "auth_tokens" ("user_id");`);

    // birth_charts
    await queryRunner.query(`
      CREATE TABLE "birth_charts" (
        "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        "user_id" uuid NOT NULL UNIQUE REFERENCES "users"("id") ON DELETE CASCADE,
        "sun_sign" varchar(20) NOT NULL,
        "moon_sign" varchar(20) NOT NULL,
        "rising_sign" varchar(20) NOT NULL,
        "birth_date" date NOT NULL,
        "birth_time" time,
        "birth_location" varchar(200),
        "created_at" timestamptz NOT NULL DEFAULT now(),
        "updated_at" timestamptz NOT NULL DEFAULT now()
      );
    `);

    // onboarding_answers
    await queryRunner.query(`
      CREATE TABLE "onboarding_answers" (
        "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        "user_id" uuid NOT NULL REFERENCES "users"("id") ON DELETE CASCADE,
        "step" smallint NOT NULL,
        "answer_json" jsonb NOT NULL,
        "created_at" timestamptz NOT NULL DEFAULT now(),
        UNIQUE ("user_id","step")
      );
    `);

    // dreams
    await queryRunner.query(`
      CREATE TABLE "dreams" (
        "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        "user_id" uuid NOT NULL REFERENCES "users"("id") ON DELETE CASCADE,
        "title" varchar(300),
        "content" text NOT NULL,
        "type_tags" varchar(20)[] NOT NULL DEFAULT '{}',
        "emotion_tags" varchar(20)[] NOT NULL DEFAULT '{}',
        "recorded_at" timestamptz NOT NULL DEFAULT now(),
        "created_at" timestamptz NOT NULL DEFAULT now(),
        "updated_at" timestamptz NOT NULL DEFAULT now(),
        "deleted_at" timestamptz,
        CONSTRAINT "chk_dreams_type_tags" CHECK (
          "type_tags" <@ ARRAY['Nightmare','Recurring','Lucid','Vivid','Fragment']::varchar[]
        ),
        CONSTRAINT "chk_dreams_emotion_tags" CHECK (
          "emotion_tags" <@ ARRAY['Peaceful','Anxious','Confused','Inspired','Heavy']::varchar[]
        )
      );
    `);
    await queryRunner.query(
      `CREATE INDEX "idx_dreams_user_recorded" ON "dreams" ("user_id","recorded_at" DESC);`,
    );
    await queryRunner.query(`
      CREATE INDEX "idx_dreams_fts"
        ON "dreams"
        USING GIN (to_tsvector('english', coalesce("title",'') || ' ' || "content"));
    `);

    // dream_interpretations
    await queryRunner.query(`
      CREATE TABLE "dream_interpretations" (
        "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        "dream_id" uuid NOT NULL UNIQUE REFERENCES "dreams"("id") ON DELETE CASCADE,
        "core_meaning" text,
        "what_reveals" text,
        "guidance" text,
        "status" "interpretation_status_enum" NOT NULL DEFAULT 'pending',
        "created_at" timestamptz NOT NULL DEFAULT now(),
        "updated_at" timestamptz NOT NULL DEFAULT now()
      );
    `);

    // dream_symbols
    await queryRunner.query(`
      CREATE TABLE "dream_symbols" (
        "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        "interpretation_id" uuid NOT NULL REFERENCES "dream_interpretations"("id") ON DELETE CASCADE,
        "emoji" varchar(10) NOT NULL,
        "name" varchar(100) NOT NULL,
        "occurrence_count" smallint NOT NULL DEFAULT 1,
        "last_seen_label" varchar(50),
        "sort_order" smallint NOT NULL DEFAULT 0
      );
    `);
    await queryRunner.query(
      `CREATE INDEX "idx_dream_symbols_interp" ON "dream_symbols" ("interpretation_id");`,
    );

    // pattern_caches
    await queryRunner.query(`
      CREATE TABLE "pattern_caches" (
        "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        "user_id" uuid NOT NULL REFERENCES "users"("id") ON DELETE CASCADE,
        "week_start" date NOT NULL,
        "symbols_json" jsonb NOT NULL DEFAULT '[]'::jsonb,
        "themes_json" jsonb NOT NULL DEFAULT '[]'::jsonb,
        "summary" text,
        "status" "pattern_cache_status_enum" NOT NULL DEFAULT 'pending',
        "generated_at" timestamptz,
        "created_at" timestamptz NOT NULL DEFAULT now(),
        UNIQUE ("user_id","week_start")
      );
    `);

    // daily_guidance
    await queryRunner.query(`
      CREATE TABLE "daily_guidance" (
        "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        "user_id" uuid NOT NULL REFERENCES "users"("id") ON DELETE CASCADE,
        "guidance_date" date NOT NULL,
        "greeting" varchar(100) NOT NULL,
        "headline" text NOT NULL,
        "subtext" text NOT NULL,
        "astro_context" varchar(200),
        "status" "daily_guidance_status_enum" NOT NULL DEFAULT 'done',
        "created_at" timestamptz NOT NULL DEFAULT now(),
        UNIQUE ("user_id","guidance_date")
      );
    `);

    // sign_reveals
    await queryRunner.query(`
      CREATE TABLE "sign_reveals" (
        "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        "user_id" uuid NOT NULL REFERENCES "users"("id") ON DELETE CASCADE,
        "position" "sign_position_enum" NOT NULL,
        "sign_name" varchar(30) NOT NULL,
        "description" text NOT NULL,
        "generated_at" timestamptz NOT NULL DEFAULT now(),
        UNIQUE ("user_id","position")
      );
    `);

    // tarot_cards
    await queryRunner.query(`
      CREATE TABLE "tarot_cards" (
        "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        "numeral" varchar(10) NOT NULL,
        "name" varchar(100) NOT NULL,
        "keywords" varchar(50)[] NOT NULL,
        "what_shows" text NOT NULL,
        "applies_today" text NOT NULL,
        "question" text NOT NULL,
        "deck_name" varchar(100) NOT NULL,
        "sort_order" smallint NOT NULL UNIQUE
      );
    `);

    // tarot_readings
    await queryRunner.query(`
      CREATE TABLE "tarot_readings" (
        "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        "user_id" uuid NOT NULL REFERENCES "users"("id") ON DELETE CASCADE,
        "card_id" uuid NOT NULL REFERENCES "tarot_cards"("id") ON DELETE CASCADE,
        "pulled_at" timestamptz NOT NULL DEFAULT now(),
        "saved" boolean NOT NULL DEFAULT false,
        "daily_date" date
      );
    `);
    await queryRunner.query(
      `CREATE UNIQUE INDEX "uq_tarot_readings_daily"
         ON "tarot_readings" ("user_id","daily_date") WHERE "daily_date" IS NOT NULL;`,
    );

    // subscription_plans
    await queryRunner.query(`
      CREATE TABLE "subscription_plans" (
        "id" varchar(20) PRIMARY KEY,
        "title" varchar(20) NOT NULL,
        "price" decimal(6,2) NOT NULL,
        "unit" varchar(5) NOT NULL,
        "badge" varchar(30),
        "sort_order" smallint NOT NULL DEFAULT 0
      );
    `);

    // user_subscriptions
    await queryRunner.query(`
      CREATE TABLE "user_subscriptions" (
        "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        "user_id" uuid NOT NULL UNIQUE REFERENCES "users"("id") ON DELETE CASCADE,
        "plan_id" varchar(20) NOT NULL REFERENCES "subscription_plans"("id"),
        "status" "subscription_status_enum" NOT NULL DEFAULT 'trial',
        "provider" "subscription_provider_enum",
        "receipt_token" text,
        "started_at" timestamptz NOT NULL DEFAULT now(),
        "trial_ends_at" timestamptz,
        "expires_at" timestamptz,
        "auto_renew" boolean NOT NULL DEFAULT true,
        "created_at" timestamptz NOT NULL DEFAULT now(),
        "updated_at" timestamptz NOT NULL DEFAULT now()
      );
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE IF EXISTS "user_subscriptions";`);
    await queryRunner.query(`DROP TABLE IF EXISTS "subscription_plans";`);
    await queryRunner.query(`DROP TABLE IF EXISTS "tarot_readings";`);
    await queryRunner.query(`DROP TABLE IF EXISTS "tarot_cards";`);
    await queryRunner.query(`DROP TABLE IF EXISTS "sign_reveals";`);
    await queryRunner.query(`DROP TABLE IF EXISTS "daily_guidance";`);
    await queryRunner.query(`DROP TABLE IF EXISTS "pattern_caches";`);
    await queryRunner.query(`DROP TABLE IF EXISTS "dream_symbols";`);
    await queryRunner.query(`DROP TABLE IF EXISTS "dream_interpretations";`);
    await queryRunner.query(`DROP TABLE IF EXISTS "dreams";`);
    await queryRunner.query(`DROP TABLE IF EXISTS "onboarding_answers";`);
    await queryRunner.query(`DROP TABLE IF EXISTS "birth_charts";`);
    await queryRunner.query(`DROP TABLE IF EXISTS "auth_tokens";`);
    await queryRunner.query(`DROP TABLE IF EXISTS "users";`);

    await queryRunner.query(`DROP TYPE IF EXISTS "subscription_provider_enum";`);
    await queryRunner.query(`DROP TYPE IF EXISTS "subscription_status_enum";`);
    await queryRunner.query(`DROP TYPE IF EXISTS "sign_position_enum";`);
    await queryRunner.query(`DROP TYPE IF EXISTS "daily_guidance_status_enum";`);
    await queryRunner.query(`DROP TYPE IF EXISTS "pattern_cache_status_enum";`);
    await queryRunner.query(`DROP TYPE IF EXISTS "interpretation_status_enum";`);
    await queryRunner.query(`DROP TYPE IF EXISTS "users_role_enum";`);
    await queryRunner.query(`DROP TYPE IF EXISTS "users_provider_enum";`);
  }
}
