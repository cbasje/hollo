import { federation } from "@fedify/fedify/x/hono";
import { Hono } from "hono";
import { serveStatic } from "hono/bun";
import { behindProxy } from "x-forwarded-fetch";
import accounts from "./accounts";
import api from "./api";
import fedi from "./federation";
import image from "./image";
import "./logging";
import login from "./login";
import oauth from "./oauth";
import setup from "./setup";

const app = new Hono();

app.use(federation(fedi, (_) => undefined));

app.use("/*", serveStatic({ root: "../dist/client/" }));
// app.use(astroHandler);
try {
  const { handler: astroHandler } = await require("../dist/server/entry.mjs");
  app.use(astroHandler);
} catch (error) {}

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
