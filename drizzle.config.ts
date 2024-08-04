import type { Config } from "drizzle-kit";

// biome-ignore lint/complexity/useLiteralKeys: tsc rants about this (TS4111)
const databaseUrl = process.env["DATABASE_URL"];
if (databaseUrl == null) throw new Error("DATABASE_URL must be defined");

export default {
  schema: ["./src/schema.ts", "./src/hunter/schema.ts"],
  out: "./drizzle",
  dialect: "postgresql",
  migrations: {
    prefix: "timestamp",
  },
  dbCredentials: {
    url: databaseUrl,
  },
} satisfies Config;
