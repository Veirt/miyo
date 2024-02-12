package handlers

import (
	"os"
	"strconv"

	"github.com/gofiber/fiber/v3"
	"github.com/veirt/miyo/api/services"
)

func UpscaleRealEsrganHandler(c fiber.Ctx) error {
	// TODO: implement validation
	form, err := c.MultipartForm()
	if err != nil {
		return c.JSON(fiber.Map{
			"err": "Error when getting form data",
		})
	}

	img, err := c.FormFile("image")
	if err != nil {
		return c.JSON(fiber.Map{
			"err": "Error when getting image",
		})
	}

	// save file to CreateTemp
	file, err := os.CreateTemp("", "image")
	defer file.Close()
	if err != nil {
		return c.JSON(fiber.Map{
			"err": "Error when creating temp file",
		})
	}

	c.SaveFile(img, file.Name())

	scale, err := strconv.Atoi(c.FormValue("scale"))
	u := upscaler.RealEsrganUpscaler{
		Scale:      scale,
		ModelName:  form.Value["modelName"][0],
		OutputType: form.Value["outputType"][0],
	}

	outputPath, err := u.Upscale(file)
	defer os.Remove(outputPath)
	if err != nil {
		return c.JSON(fiber.Map{
			"err": "Error when upscaling image",
		})
	}

	return c.SendFile(outputPath)
}

func UpscaleWaifu2xHandler(c fiber.Ctx) error {
	// TODO: implement validation
	// form, err := c.MultipartForm()
	// if err != nil {
	// 	return c.JSON(fiber.Map{
	// 		"err": "Error when getting form data",
	// 	})
	// }
	//
	// img, err := c.FormFile("image")
	// if err != nil {
	// 	return c.JSON(fiber.Map{
	// 		"err": "Error when getting image",
	// 	})
	// }
	//
	// file, err := os.CreateTemp("", "image")
	// defer file.Close()

	return c.SendFile("./test")
}
