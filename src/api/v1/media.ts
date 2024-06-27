import { eq } from "drizzle-orm";
import { Hono } from "hono";
import { db } from "../../db";
import { serializeMedium } from "../../entities/medium";
import { type Variables, scopeRequired, tokenRequired } from "../../oauth";
import { media } from "../../schema";

const app = new Hono<{ Variables: Variables }>();

app.get("/:id", async (c) => {
  const medium = await db.query.media.findFirst({
    where: eq(media.id, c.req.param("id")),
  });
  if (medium == null) return c.json({ error: "Not found" }, 404);
  return c.json(serializeMedium(medium));
});

app.put("/:id", tokenRequired, scopeRequired(["write:media"]), async (c) => {
  const mediumId = c.req.param("id");
  let description: string | undefined;
  try {
    const json = await c.req.json();
    description = json.description;
  } catch (e) {
    const form = await c.req.formData();
    description = form.get("description")?.toString();
  }
  if (description == null) {
    return c.json({ error: "description is required" }, 422);
  }
  const result = await db
    .update(media)
    .set({ description })
    .where(eq(media.id, mediumId))
    .returning();
  if (result.length < 1) return c.json({ error: "Not found" }, 404);
  return c.json(serializeMedium(result[0]));
});

export default app;
