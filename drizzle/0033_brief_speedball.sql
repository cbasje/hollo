DO $$ BEGIN
 CREATE TYPE "public"."series" AS ENUM('F1', 'F2', 'F3', 'FE', 'INDY', 'NXT', 'WEC', 'WRC', 'F1A');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 CREATE TYPE "public"."session_types" AS ENUM('R', 'S', 'SQ', 'Q', 'FP', 'T', 'TBC', 'W');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "circuits" (
	"id" serial PRIMARY KEY NOT NULL,
	"title" text NOT NULL,
	"used_titles" text[],
	"wikipedia_page_id" integer,
	"locality" text,
	"country" text,
	"timezone" text,
	"utc_offset" integer,
	"lon" real,
	"lat" real,
	"created_at" timestamp (3) DEFAULT now(),
	"updated_at" timestamp (3) NOT NULL,
	CONSTRAINT "circuits_title_unique" UNIQUE("title"),
	CONSTRAINT "circuits_wikipedia_page_id_unique" UNIQUE("wikipedia_page_id")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "rounds" (
	"id" text PRIMARY KEY NOT NULL,
	"number" integer DEFAULT 0 NOT NULL,
	"title" text NOT NULL,
	"season" text NOT NULL,
	"link" text,
	"start" date,
	"end" date,
	"circuit_id" integer NOT NULL,
	"series" "series",
	"created_at" timestamp (3) DEFAULT now(),
	"updated_at" timestamp (3) NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "sessions" (
	"id" text PRIMARY KEY NOT NULL,
	"number" integer DEFAULT 0 NOT NULL,
	"start" timestamp NOT NULL,
	"end" timestamp NOT NULL,
	"round_id" text NOT NULL,
	"type" "session_types",
	"created_at" timestamp (3) DEFAULT now(),
	"updated_at" timestamp (3) NOT NULL
);
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "rounds" ADD CONSTRAINT "rounds_circuit_id_circuits_id_fk" FOREIGN KEY ("circuit_id") REFERENCES "public"."circuits"("id") ON DELETE set null ON UPDATE set null;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "sessions" ADD CONSTRAINT "sessions_round_id_rounds_id_fk" FOREIGN KEY ("round_id") REFERENCES "public"."rounds"("id") ON DELETE cascade ON UPDATE cascade;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
