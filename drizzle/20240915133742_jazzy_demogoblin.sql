DO $$ BEGIN
 CREATE TYPE "public"."account_type" AS ENUM('Application', 'Group', 'Organization', 'Person', 'Service');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 CREATE TYPE "public"."grant_type" AS ENUM('authorization_code', 'client_credentials');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 CREATE TYPE "public"."list_replies_policy" AS ENUM('followed', 'list', 'none');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 CREATE TYPE "public"."marker_type" AS ENUM('notifications', 'home');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 CREATE TYPE "public"."post_type" AS ENUM('Article', 'Note', 'Question');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 CREATE TYPE "public"."post_visibility" AS ENUM('public', 'unlisted', 'private', 'direct');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 CREATE TYPE "public"."scope" AS ENUM('read', 'read:accounts', 'read:blocks', 'read:bookmarks', 'read:favourites', 'read:filters', 'read:follows', 'read:lists', 'read:mutes', 'read:notifications', 'read:search', 'read:statuses', 'write', 'write:accounts', 'write:blocks', 'write:bookmarks', 'write:conversations', 'write:favourites', 'write:filters', 'write:follows', 'write:lists', 'write:media', 'write:mutes', 'write:notifications', 'write:reports', 'write:statuses', 'follow', 'push');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
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
CREATE TABLE IF NOT EXISTS "hollo_access_tokens" (
	"code" text PRIMARY KEY NOT NULL,
	"application_id" uuid NOT NULL,
	"account_owner_id" uuid,
	"grant_type" "grant_type" DEFAULT 'authorization_code' NOT NULL,
	"scopes" scope[] NOT NULL,
	"created" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "hollo_account_owners" (
	"id" uuid PRIMARY KEY NOT NULL,
	"handle" text NOT NULL,
	"rsa_private_key_jwk" jsonb NOT NULL,
	"rsa_public_key_jwk" jsonb NOT NULL,
	"ed25519_private_key_jwk" jsonb NOT NULL,
	"ed25519_public_key_jwk" jsonb NOT NULL,
	"fields" json DEFAULT '{}'::json NOT NULL,
	"bio" text,
	"followed_tags" text[] NOT NULL,
	"visibility" "post_visibility" DEFAULT 'public' NOT NULL,
	"language" text DEFAULT 'en' NOT NULL,
	CONSTRAINT "hollo_account_owners_handle_unique" UNIQUE("handle")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "hollo_accounts" (
	"id" uuid PRIMARY KEY NOT NULL,
	"iri" text NOT NULL,
	"type" "account_type" NOT NULL,
	"name" varchar(100) NOT NULL,
	"handle" text NOT NULL,
	"bio_html" text,
	"url" text,
	"protected" boolean DEFAULT false NOT NULL,
	"avatar_url" text,
	"cover_url" text,
	"inbox_url" text NOT NULL,
	"followers_url" text,
	"shared_inbox_url" text,
	"featured_url" text,
	"following_count" bigint DEFAULT 0,
	"followers_count" bigint DEFAULT 0,
	"posts_count" bigint DEFAULT 0,
	"field_htmls" json DEFAULT '{}'::json NOT NULL,
	"sensitive" boolean DEFAULT false NOT NULL,
	"published" timestamp with time zone,
	"updated" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "hollo_accounts_iri_unique" UNIQUE("iri"),
	CONSTRAINT "hollo_accounts_handle_unique" UNIQUE("handle")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "hollo_applications" (
	"id" uuid PRIMARY KEY NOT NULL,
	"name" varchar(256) NOT NULL,
	"redirect_uris" text[] NOT NULL,
	"scopes" scope[] NOT NULL,
	"website" text,
	"client_id" text NOT NULL,
	"client_secret" text NOT NULL,
	"created" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "hollo_applications_client_id_unique" UNIQUE("client_id")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "hollo_bookmarks" (
	"post_id" uuid NOT NULL,
	"account_owner_id" uuid NOT NULL,
	"created" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "hollo_bookmarks_post_id_account_owner_id_pk" PRIMARY KEY("post_id","account_owner_id")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "hollo_credentials" (
	"email" varchar(254) PRIMARY KEY NOT NULL,
	"password_hash" text NOT NULL,
	"created" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "hollo_featured_tags" (
	"id" uuid PRIMARY KEY NOT NULL,
	"account_owner_id" uuid NOT NULL,
	"name" text NOT NULL,
	"created" timestamp with time zone,
	CONSTRAINT "hollo_featured_tags_account_owner_id_name_unique" UNIQUE("account_owner_id","name")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "hollo_follows" (
	"iri" text NOT NULL,
	"following_id" uuid NOT NULL,
	"follower_id" uuid NOT NULL,
	"shares" boolean DEFAULT true NOT NULL,
	"notify" boolean DEFAULT false NOT NULL,
	"languages" text[],
	"created" timestamp with time zone DEFAULT now() NOT NULL,
	"approved" timestamp with time zone,
	CONSTRAINT "hollo_follows_following_id_follower_id_pk" PRIMARY KEY("following_id","follower_id"),
	CONSTRAINT "hollo_follows_iri_unique" UNIQUE("iri")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "hollo_likes" (
	"post_id" uuid NOT NULL,
	"account_id" uuid NOT NULL,
	"created" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "hollo_likes_post_id_account_id_pk" PRIMARY KEY("post_id","account_id")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "hollo_list_members" (
	"list_id" uuid NOT NULL,
	"account_id" uuid NOT NULL,
	"created" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "hollo_list_members_list_id_account_id_pk" PRIMARY KEY("list_id","account_id")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "hollo_lists" (
	"id" uuid PRIMARY KEY NOT NULL,
	"account_owner_id" uuid NOT NULL,
	"title" text NOT NULL,
	"replies_policy" "list_replies_policy" DEFAULT 'list' NOT NULL,
	"exclusive" boolean DEFAULT false NOT NULL,
	"created" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "hollo_markers" (
	"account_owner_id" uuid NOT NULL,
	"type" "marker_type" NOT NULL,
	"last_read_id" text NOT NULL,
	"version" bigint DEFAULT 1 NOT NULL,
	"updated" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "hollo_markers_account_owner_id_type_pk" PRIMARY KEY("account_owner_id","type")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "hollo_media" (
	"id" uuid PRIMARY KEY NOT NULL,
	"post_id" uuid,
	"type" text NOT NULL,
	"url" text NOT NULL,
	"width" integer NOT NULL,
	"height" integer NOT NULL,
	"description" text,
	"thumbnail_type" text NOT NULL,
	"thumbnail_url" text NOT NULL,
	"thumbnail_width" integer NOT NULL,
	"thumbnail_height" integer NOT NULL,
	"created" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "hollo_mentions" (
	"post_id" uuid NOT NULL,
	"account_id" uuid NOT NULL,
	CONSTRAINT "hollo_mentions_post_id_account_id_pk" PRIMARY KEY("post_id","account_id")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "hollo_mutes" (
	"id" uuid PRIMARY KEY NOT NULL,
	"account_id" uuid NOT NULL,
	"muted_account_id" uuid NOT NULL,
	"notifications" boolean DEFAULT true NOT NULL,
	"duration" integer DEFAULT 0 NOT NULL,
	"created" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "mutes_account_id_muted_account_id_unique" UNIQUE("account_id","muted_account_id")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "hollo_pinned_posts" (
	"index" bigserial PRIMARY KEY NOT NULL,
	"post_id" uuid NOT NULL,
	"account_id" uuid NOT NULL,
	"created" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "hollo_pinned_posts_post_id_account_id_unique" UNIQUE("post_id","account_id")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "hollo_poll_options" (
	"poll_id" uuid,
	"index" integer NOT NULL,
	"title" text NOT NULL,
	"votes_count" bigint DEFAULT 0 NOT NULL,
	CONSTRAINT "hollo_poll_options_poll_id_index_pk" PRIMARY KEY("poll_id","index"),
	CONSTRAINT "hollo_poll_options_poll_id_title_unique" UNIQUE("poll_id","title")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "hollo_poll_votes" (
	"poll_id" uuid NOT NULL,
	"option_index" integer NOT NULL,
	"account_id" uuid NOT NULL,
	"created" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "hollo_poll_votes_poll_id_option_index_account_id_pk" PRIMARY KEY("poll_id","option_index","account_id")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "hollo_polls" (
	"id" uuid PRIMARY KEY NOT NULL,
	"multiple" boolean DEFAULT false NOT NULL,
	"voters_count" bigint DEFAULT 0 NOT NULL,
	"expires" timestamp with time zone NOT NULL,
	"created" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "hollo_posts" (
	"id" uuid PRIMARY KEY NOT NULL,
	"iri" text NOT NULL,
	"type" "post_type" NOT NULL,
	"actor_id" uuid NOT NULL,
	"application_id" uuid,
	"reply_target_id" uuid,
	"sharing_id" uuid,
	"quote_target_id" uuid,
	"visibility" "post_visibility" NOT NULL,
	"summary_html" text,
	"summary" text,
	"content_html" text,
	"content" text,
	"poll_id" uuid,
	"language" text,
	"tags" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"sensitive" boolean DEFAULT false NOT NULL,
	"url" text,
	"preview_card" jsonb,
	"replies_count" bigint DEFAULT 0,
	"shares_count" bigint DEFAULT 0,
	"likes_count" bigint DEFAULT 0,
	"published" timestamp with time zone,
	"updated" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "hollo_posts_iri_unique" UNIQUE("iri"),
	CONSTRAINT "posts_id_actor_id_unique" UNIQUE("id","actor_id"),
	CONSTRAINT "hollo_posts_poll_id_unique" UNIQUE("poll_id")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "porpoise_circuits" (
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
	CONSTRAINT "porpoise_circuits_title_unique" UNIQUE("title"),
	CONSTRAINT "porpoise_circuits_wikipedia_page_id_unique" UNIQUE("wikipedia_page_id")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "porpoise_rounds" (
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
CREATE TABLE IF NOT EXISTS "porpoise_sessions" (
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
 ALTER TABLE "hollo_access_tokens" ADD CONSTRAINT "hollo_access_tokens_application_id_hollo_applications_id_fk" FOREIGN KEY ("application_id") REFERENCES "public"."hollo_applications"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_access_tokens" ADD CONSTRAINT "hollo_access_tokens_account_owner_id_hollo_account_owners_id_fk" FOREIGN KEY ("account_owner_id") REFERENCES "public"."hollo_account_owners"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_account_owners" ADD CONSTRAINT "hollo_account_owners_id_hollo_accounts_id_fk" FOREIGN KEY ("id") REFERENCES "public"."hollo_accounts"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_bookmarks" ADD CONSTRAINT "hollo_bookmarks_post_id_hollo_posts_id_fk" FOREIGN KEY ("post_id") REFERENCES "public"."hollo_posts"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_bookmarks" ADD CONSTRAINT "hollo_bookmarks_account_owner_id_hollo_account_owners_id_fk" FOREIGN KEY ("account_owner_id") REFERENCES "public"."hollo_account_owners"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_featured_tags" ADD CONSTRAINT "hollo_featured_tags_account_owner_id_hollo_account_owners_id_fk" FOREIGN KEY ("account_owner_id") REFERENCES "public"."hollo_account_owners"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_follows" ADD CONSTRAINT "hollo_follows_following_id_hollo_accounts_id_fk" FOREIGN KEY ("following_id") REFERENCES "public"."hollo_accounts"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_follows" ADD CONSTRAINT "hollo_follows_follower_id_hollo_accounts_id_fk" FOREIGN KEY ("follower_id") REFERENCES "public"."hollo_accounts"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_likes" ADD CONSTRAINT "hollo_likes_post_id_hollo_posts_id_fk" FOREIGN KEY ("post_id") REFERENCES "public"."hollo_posts"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_likes" ADD CONSTRAINT "hollo_likes_account_id_hollo_accounts_id_fk" FOREIGN KEY ("account_id") REFERENCES "public"."hollo_accounts"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_list_members" ADD CONSTRAINT "hollo_list_members_list_id_hollo_lists_id_fk" FOREIGN KEY ("list_id") REFERENCES "public"."hollo_lists"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_list_members" ADD CONSTRAINT "hollo_list_members_account_id_hollo_accounts_id_fk" FOREIGN KEY ("account_id") REFERENCES "public"."hollo_accounts"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_lists" ADD CONSTRAINT "hollo_lists_account_owner_id_hollo_account_owners_id_fk" FOREIGN KEY ("account_owner_id") REFERENCES "public"."hollo_account_owners"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_markers" ADD CONSTRAINT "hollo_markers_account_owner_id_hollo_account_owners_id_fk" FOREIGN KEY ("account_owner_id") REFERENCES "public"."hollo_account_owners"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_media" ADD CONSTRAINT "hollo_media_post_id_hollo_posts_id_fk" FOREIGN KEY ("post_id") REFERENCES "public"."hollo_posts"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_mentions" ADD CONSTRAINT "hollo_mentions_post_id_hollo_posts_id_fk" FOREIGN KEY ("post_id") REFERENCES "public"."hollo_posts"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_mentions" ADD CONSTRAINT "hollo_mentions_account_id_hollo_accounts_id_fk" FOREIGN KEY ("account_id") REFERENCES "public"."hollo_accounts"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_mutes" ADD CONSTRAINT "hollo_mutes_account_id_hollo_accounts_id_fk" FOREIGN KEY ("account_id") REFERENCES "public"."hollo_accounts"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_mutes" ADD CONSTRAINT "hollo_mutes_muted_account_id_hollo_accounts_id_fk" FOREIGN KEY ("muted_account_id") REFERENCES "public"."hollo_accounts"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_pinned_posts" ADD CONSTRAINT "hollo_pinned_posts_account_id_hollo_accounts_id_fk" FOREIGN KEY ("account_id") REFERENCES "public"."hollo_accounts"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_pinned_posts" ADD CONSTRAINT "hollo_pinned_posts_post_id_account_id_hollo_posts_id_actor_id_fk" FOREIGN KEY ("post_id","account_id") REFERENCES "public"."hollo_posts"("id","actor_id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_poll_options" ADD CONSTRAINT "hollo_poll_options_poll_id_hollo_polls_id_fk" FOREIGN KEY ("poll_id") REFERENCES "public"."hollo_polls"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_poll_votes" ADD CONSTRAINT "hollo_poll_votes_poll_id_hollo_polls_id_fk" FOREIGN KEY ("poll_id") REFERENCES "public"."hollo_polls"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_poll_votes" ADD CONSTRAINT "hollo_poll_votes_account_id_hollo_accounts_id_fk" FOREIGN KEY ("account_id") REFERENCES "public"."hollo_accounts"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_poll_votes" ADD CONSTRAINT "hollo_poll_votes_poll_id_option_index_hollo_poll_options_poll_id_index_fk" FOREIGN KEY ("poll_id","option_index") REFERENCES "public"."hollo_poll_options"("poll_id","index") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_posts" ADD CONSTRAINT "hollo_posts_actor_id_hollo_accounts_id_fk" FOREIGN KEY ("actor_id") REFERENCES "public"."hollo_accounts"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_posts" ADD CONSTRAINT "hollo_posts_application_id_hollo_applications_id_fk" FOREIGN KEY ("application_id") REFERENCES "public"."hollo_applications"("id") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_posts" ADD CONSTRAINT "hollo_posts_reply_target_id_hollo_posts_id_fk" FOREIGN KEY ("reply_target_id") REFERENCES "public"."hollo_posts"("id") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_posts" ADD CONSTRAINT "hollo_posts_sharing_id_hollo_posts_id_fk" FOREIGN KEY ("sharing_id") REFERENCES "public"."hollo_posts"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_posts" ADD CONSTRAINT "hollo_posts_quote_target_id_hollo_posts_id_fk" FOREIGN KEY ("quote_target_id") REFERENCES "public"."hollo_posts"("id") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "hollo_posts" ADD CONSTRAINT "hollo_posts_poll_id_hollo_polls_id_fk" FOREIGN KEY ("poll_id") REFERENCES "public"."hollo_polls"("id") ON DELETE set null ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "porpoise_rounds" ADD CONSTRAINT "porpoise_rounds_circuit_id_porpoise_circuits_id_fk" FOREIGN KEY ("circuit_id") REFERENCES "public"."porpoise_circuits"("id") ON DELETE set null ON UPDATE set null;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "porpoise_sessions" ADD CONSTRAINT "porpoise_sessions_round_id_porpoise_rounds_id_fk" FOREIGN KEY ("round_id") REFERENCES "public"."porpoise_rounds"("id") ON DELETE cascade ON UPDATE cascade;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
