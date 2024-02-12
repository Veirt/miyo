// https://github.com/xinntao/Real-ESRGAN-ncnn-vulkan
// Usage: realesrgan-ncnn-vulkan -i infile -o outfile [options]...
//
//   -h                   show this help
//   -i input-path        input image path (jpg/png/webp) or directory
//   -o output-path       output image path (jpg/png/webp) or directory
//   -s scale             upscale ratio (can be 2, 3, 4. default=4)
//   -t tile-size         tile size (>=32/0=auto, default=0) can be 0,0,0 for multi-gpu
//   -m model-path        folder path to the pre-trained models. default=models
//   -n model-name        model name (default=realesr-animevideov3, can be realesr-animevideov3 | realesrgan-x4plus | realesrgan-x4plus-anime | realesrnet-x4plus)
//   -g gpu-id            gpu device to use (default=auto) can be 0,1,2 for multi-gpu
//   -j load:proc:save    thread count for load/proc/save (default=1:2:2) can be 1:2,2,2:2 for multi-gpu
//   -x                   enable tta mode
//   -f format            output image format (jpg/png/webp, default=ext/png)
//   -v                   verbose output

import { dev } from "$app/environment";

interface Upscaler {
  key: string;
  name: string;
  scale: {
    default: number;
    available: number[];
  };
  denoiseLevel?: {
    default: number;
    available: number[];
  };
  modelName: string[];
}

export const realesrgan: Upscaler = {
  key: "realesrgan",
  name: "Real-ESRGAN",
  scale: {
    default: 4,
    available: [2, 3, 4],
  },
  modelName: [
    "realesr-animevideov3",
    "realesrgan-x4plus",
    "realesrgan-x4plus-anime",
    "realesrnet-x4plus",
  ],
};

// https://github.com/nihui/waifu2x-ncnn-vulkan
// Usage: waifu2x-ncnn-vulkan -i infile -o outfile [options]...
//
//   -h                   show this help
//   -v                   verbose output
//   -i input-path        input image path (jpg/png/webp) or directory
//   -o output-path       output image path (jpg/png/webp) or directory
//   -n noise-level       denoise level (-1/0/1/2/3, default=0)
//   -s scale             upscale ratio (1/2/4/8/16/32, default=2)
//   -t tile-size         tile size (>=32/0=auto, default=0) can be 0,0,0 for multi-gpu
//   -m model-path        waifu2x model path (default=models-cunet)
//   -g gpu-id            gpu device to use (-1=cpu, default=auto) can be 0,1,2 for multi-gpu
//   -j load:proc:save    thread count for load/proc/save (default=1:2:2) can be 1:2,2,2:2 for multi-gpu
//   -x                   enable tta mode
//   -f format            output image format (jpg/png/webp, default=ext/png)
export const waifu2x: Upscaler = {
  key: "waifu2x",
  name: "waifu2x",
  scale: {
    default: 2,
    // like what, I don't want people to use 32x. My server will die.
    available: dev ? [1, 2, 4, 8, 16, 32] : [1, 2, 4, 8],
  },
  denoiseLevel: {
    default: 0,
    available: [-1, 0, 1, 2, 3],
  },
  modelName: ["models-cunet"],
};

export const upscalers = { realesrgan, waifu2x };
