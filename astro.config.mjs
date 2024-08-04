import { defineConfig } from "astro/config";

import hono from "./adapter/index";
import icon from "astro-icon";

// https://astro.build/config
export default defineConfig({
  output: "server",
  adapter: hono(),

  experimental: {
    serverIslands: true,
  },

  integrations: [
    icon({
      include: {
        "fluent-emoji-high-contrast": [
          "dashing-away",
          "boy",
          "baby",
          "battery",
          "eagle",
          "baby-chick",
          "stopwatch",
          "snow-capped-mountain",
          "girl",
          "police-car-light",
        ],
      },
      svgoOptions: {
        plugins: [
          {
            name: "convertColors",
            params: {
              currentColor: true,
            },
          },
        ],
      },
    }),
  ],
});
