#!/usr/bin/env bash

waifu2x="https://github.com/nihui/waifu2x-ncnn-vulkan/releases/download/20220728/waifu2x-ncnn-vulkan-20220728-ubuntu.zip"
dir="$(basename $waifu2x .zip)"

wget "$waifu2x" --no-clobber -O upscaler/waifu2x.zip
unzip -n -j upscaler/waifu2x.zip "*waifu2x-ncnn-vulkan" -d upscaler
unzip -n upscaler/waifu2x.zip "*models*" -d upscaler &&
    cp -fr upscaler/$dir/* "upscaler" &&
    rm -rf upscaler/$dir

realesrgan="https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-ubuntu.zip"
wget "$realesrgan" --no-clobber -O upscaler/realesrgan.zip
unzip -n -j upscaler/realesrgan.zip realesrgan-ncnn-vulkan -d upscaler
unzip -n -j upscaler/realesrgan.zip "*models*" -d upscaler/models-realesrgan

chmod +x upscaler/*
