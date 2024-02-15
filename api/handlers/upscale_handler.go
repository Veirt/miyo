package handlers

import (
	"github.com/gofiber/fiber/v3"
	"github.com/veirt/miyo/api/services"
	"os"
)

func saveTempImage(c fiber.Ctx) (*os.File, error) {
	img, err := c.FormFile("image")
	if img == nil || err != nil {
		return nil, err
	}

	// save file to CreateTemp
	file, err := os.CreateTemp("", "image")
	defer file.Close()
	if err != nil {
		return nil, err
	}

	c.SaveFile(img, file.Name())

	return file, nil
}

func UpscaleRealEsrganHandler(c fiber.Ctx) error {
	upscaler := &services.RealEsrganUpscaler{
		Scale:      c.FormValue("scale"),
		ModelName:  c.FormValue("modelName"),
		OutputType: c.FormValue("outputType"),
	}

	res := services.Validator.GetMessage(upscaler)
	if !res.Success {
		return c.Status(fiber.StatusBadRequest).JSON(res)
	}

	file, err := saveTempImage(c)
	if file == nil || err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"success": false,
			"message": "Failed to get the image",
		})
	}
	defer os.Remove(file.Name())

	i := services.Image{
		File: file,
	}
	outPath, err := i.Upscale(upscaler)
	defer os.Remove(outPath)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"success": false,
			"message": "Failed to upscale image [realesrgan]",
		})
	}

	return c.SendFile(outPath)
}

func UpscaleWaifu2xHandler(c fiber.Ctx) error {
	upscaler := &services.Waifu2xUpscaler{
		Scale:        c.FormValue("scale"),
		ModelName:    c.FormValue("modelName"),
		DenoiseLevel: c.FormValue("denoiseLevel"),
		OutputType:   c.FormValue("outputType"),
	}

	res := services.Validator.GetMessage(upscaler)
	if !res.Success {
		return c.Status(fiber.StatusBadRequest).JSON(res)
	}

	file, err := saveTempImage(c)
	if file == nil || err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"success": false,
			"message": "Failed to get the image",
		})
	}
	defer os.Remove(file.Name())

	i := services.Image{
		File: file,
	}
	outPath, err := i.Upscale(upscaler)
	defer os.Remove(outPath)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"success": false,
			"message": "Failed to upscale the image [waifu2x]",
		})
	}

	return c.SendFile(outPath)
}
