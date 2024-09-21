CREATE INDEX IF NOT EXISTS "hollo_bookmarks_post_id_account_owner_id_index" ON "hollo_bookmarks" USING btree ("post_id","account_owner_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "hollo_media_post_id_index" ON "hollo_media" USING btree ("post_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "hollo_poll_votes_poll_id_account_id_index" ON "hollo_poll_votes" USING btree ("poll_id","account_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "hollo_posts_sharing_id_index" ON "hollo_posts" USING btree ("sharing_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "hollo_posts_actor_id_sharing_id_index" ON "hollo_posts" USING btree ("actor_id","sharing_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "hollo_posts_reply_target_id_index" ON "hollo_posts" USING btree ("reply_target_id");