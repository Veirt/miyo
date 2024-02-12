// uno.config.ts
import {
  defineConfig,
  presetUno,
  presetWind,
  transformerDirectives,
} from "unocss";
import presetIcons from "@unocss/preset-icons";

export default defineConfig({
  presets: [presetUno(), presetWind(), presetIcons()],
  theme: {
    colors: {
      text: "#e6e7ec",
      background: "#0b0c0f",
      alt: "#141519",
      primary: "#b5b8c6",
      secondary: "#574358",
      accent: "#a2859b",
    },
  },
  transformers: [transformerDirectives()],
});
