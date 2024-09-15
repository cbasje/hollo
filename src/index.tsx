import { federation as honoFedifyMiddleware } from "@fedify/fedify/x/hono";
import { Hono } from "hono";
import { serveStatic } from "hono/bun";
import { behindProxy } from "x-forwarded-fetch";
import accounts from "./accounts";
import api from "./api";
import federation from "./federation";
import hunter from "./hunter";
import image from "./image";
import oauth from "./oauth";
import "./logging";
import pages from "./pages";

export type EnvVariables = {
  PUBLIC_MAP_API_KEY: string;
  GEOCODING_API_KEY: string;
  WEATHER_API_KEY: string;

  INCLUDED_SERIES?: string;

  F1A_API_KEY: string;
  F2_API_KEY: string;
  F3_API_KEY: string;
};

const app = new Hono();

// Add Fedify setup
app.use(honoFedifyMiddleware(federation, (_) => undefined));

// Add pre-built Astro routes
app.use("/*", serveStatic({ root: "./dist/client/" }));
try {
  // To prevent `astro check` complaining before build
  const { handler: astroHandler } = await require("../dist/server/entry.mjs");
  app.use(astroHandler);
} catch (error) {}

// Add hunter
app.route("/hunter", hunter);

// Add rest routes
app.route("/setup", setup);
app.route("/login", login);
app.route("/accounts", accounts);
app.route("/oauth", oauth);
app.route("/api", api);
app.route("/image", image);
app.get("/nodeinfo/2.0", (c) => c.redirect("/nodeinfo/2.1"));

// biome-ignore lint/complexity/useLiteralKeys: tsc complains about this (TS4111)
const BEHIND_PROXY = process.env["BEHIND_PROXY"] === "true";

export default BEHIND_PROXY ? { fetch: behindProxy(app.fetch.bind(app)) } : app;
