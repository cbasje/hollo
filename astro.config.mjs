import { defineConfig } from "astro/config";

import hono from "./adapter/index";

// https://astro.build/config
export default defineConfig({
    output: "server",
    adapter: hono(),
});
