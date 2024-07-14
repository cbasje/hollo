import type { SSRManifest } from "astro";
import { App } from "astro/app";
import { createMiddleware } from "./middleware";

export function createExports(manifest: SSRManifest) {
  const app = new App(manifest);
  const handler = createMiddleware(app);
  return { handler };
}
