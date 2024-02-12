import { sveltekit } from "@sveltejs/kit/vite";
import { defineConfig } from "vite";
import UnoCSS from "unocss/vite";
import extractorSvelte from "@unocss/extractor-svelte";

export default defineConfig({
  plugins: [
    UnoCSS({
      extractors: [extractorSvelte()],
      // ...other Svelte Scoped options
    }),
    sveltekit(),
  ],
  server: {
    proxy: {
      "/api": {
        target: "http://localhost:3000",
        changeOrigin: true,
      },
    },
  },
});
