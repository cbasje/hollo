import { defineMiddleware } from "astro:middleware";
import db from "./db";

export const onRequest = defineMiddleware(async (context, next) => {
  const credential = await db.query.credentials.findFirst();
  if (credential == null) return context.rewrite(new Request("/setup"));

  return next();
});
