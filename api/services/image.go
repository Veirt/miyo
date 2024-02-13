package services

import "os"

type Image struct {
	File *os.File
}

func (i Image) Upscale(upscaler Upscaler) (string, error) {
	outPath, err := upscaler.Upscale(i.File)
	if err != nil {
		return "", err
	}

	return outPath, nil
}
