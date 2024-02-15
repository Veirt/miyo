package main

import (
	"github.com/gofiber/fiber/v3"
	"github.com/veirt/miyo/api/handlers"
)

func main() {
	app := fiber.New()
	app.Static("/", "./dist")

	api := app.Group("/api") // /api
	api.Post("/upscale/realesrgan", func(c fiber.Ctx) error {
		return handlers.UpscaleRealEsrganHandler(c)
	})
	api.Post("/upscale/waifu2x", func(c fiber.Ctx) error {
		return handlers.UpscaleWaifu2xHandler(c)
	})

	app.Listen(":3000")
}
