package services

import (
	"os"
	"os/exec"

	"github.com/google/uuid"
)

type Upscaler interface {
	Upscale(file *os.File) (string, error)
}

func getOutputPath(outType string) string {
	outDir := "out"
	outPath := outDir + "/" + uuid.New().String() + "." + outType

	return outPath
}

// Usage: realesrgan-ncnn-vulkan -i infile -o outfile [options]...
//
//	-h                   show this help
//	-i input-path        input image path (jpg/png/webp) or directory
//	-o output-path       output image path (jpg/png/webp) or directory
//	-s scale             upscale ratio (can be 2, 3, 4. default=4)
//	-t tile-size         tile size (>=32/0=auto, default=0) can be 0,0,0 for multi-gpu
//	-m model-path        folder path to the pre-trained models. default=models
//	-n model-name        model name (default=realesr-animevideov3, can be realesr-animevideov3 | realesrgan-x4plus | realesrgan-x4plus-anime | realesrnet-x4plus)
//	-g gpu-id            gpu device to use (default=auto) can be 0,1,2 for multi-gpu
//	-j load:proc:save    thread count for load/proc/save (default=1:2:2) can be 1:2,2,2:2 for multi-gpu
//	-x                   enable tta mode
//	-f format            output image format (jpg/png/webp, default=ext/png)
type RealEsrganUpscaler struct {
	Scale      string `json:"scale" validate:"required,oneof=2 3 4"`
	ModelName  string `json:"modelName" validate:"required,oneof=realesr-animevideov3 realesrgan-x4plus realesrgan-x4plus-anime realesrnet-x4plus"`
	OutputType string `json:"outputType" validate:"required,oneof=jpg png webp"`
}

func (u *RealEsrganUpscaler) Upscale(file *os.File) (string, error) {
	outPath := getOutputPath(u.OutputType)
	cmd := exec.Command("realesrgan-ncnn-vulkan", "-i", file.Name(), "-o", outPath, "-s", u.Scale, "-n", u.ModelName, "-f", u.OutputType)
	err := cmd.Run()

	if err != nil {
		return "", err
	}

	return outPath, nil
}

// Usage: waifu2x-ncnn-vulkan -i infile -o outfile [options]...
//
//	-h                   show this help
//	-v                   verbose output
//	-i input-path        input image path (jpg/png/webp) or directory
//	-o output-path       output image path (jpg/png/webp) or directory
//	-n noise-level       denoise level (-1/0/1/2/3, default=0)
//	-s scale             upscale ratio (1/2/4/8/16/32, default=2)
//	-t tile-size         tile size (>=32/0=auto, default=0) can be 0,0,0 for multi-gpu
//	-m model-path        waifu2x model path (default=models-cunet)
//	-g gpu-id            gpu device to use (-1=cpu, default=auto) can be 0,1,2 for multi-gpu
//	-j load:proc:save    thread count for load/proc/save (default=1:2:2) can be 1:2,2,2:2 for multi-gpu
//	-x                   enable tta mode
//	-f format            output image format (jpg/png/webp, default=ext/png)
type Waifu2xUpscaler struct {
	Scale        string `json:"scale" validate:"required,oneof=1 2 4 8 16 32"`
	DenoiseLevel string `json:"denoiseLevel" validate:"required,oneof=-1 0 1 2 3"`
	ModelName    string `json:"modelName" validate:"required,oneof=models-cunet"`
	OutputType   string `json:"outputType" validate:"required,oneof=jpg png webp"`
}

func (u *Waifu2xUpscaler) Upscale(file *os.File) (string, error) {
	outPath := getOutputPath(u.OutputType)
	cmd := exec.Command("waifu2x-ncnn-vulkan", "-i", file.Name(), "-o", outPath, "-s", u.Scale, "-n", u.DenoiseLevel, "-f", u.OutputType)
	err := cmd.Run()

	if err != nil {
		return "", err
	}

	return outPath, nil
}
