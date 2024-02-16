FROM oven/bun:1-alpine AS webbuilder

WORKDIR /app/src
COPY web/package.json web/bun.lockb ./
RUN bun install --frozen-lockfile

COPY web/ .

ENV NODE_ENV=production
RUN bun run build
# dist will be in /app/dist

FROM golang:1.22-alpine AS apibuilder

WORKDIR /app
COPY go.* ./
RUN go mod download

COPY . .
RUN go build -o miyo cmd/main.go

FROM alpine:edge AS downloader
WORKDIR /download
ENV realesrgan_url "https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-ubuntu.zip"
RUN apk add --no-cache wget unzip \ 
    && mkdir -p upscaler \
    && wget -q "$realesrgan_url" --no-clobber -O upscaler/realesrgan.zip \
    && unzip -n -j upscaler/realesrgan.zip "*models*" -d upscaler/models-realesrgan \
    && rm -rf upscaler/*.zip

FROM alpine:edge AS compiler
RUN apk add --no-cache git vulkan-headers vulkan-loader-dev glslang cmake make gcc g++

WORKDIR /app
RUN git clone https://github.com/nihui/waifu2x-ncnn-vulkan.git --depth 1 \
    && cd waifu2x-ncnn-vulkan || exit \
    && git submodule update --init --recursive \
    && mkdir build \
    && cd build || exit \
    && cmake ../src \
    && cmake --build . -j "$(nproc)"

WORKDIR /app
RUN git clone https://github.com/xinntao/Real-ESRGAN-ncnn-vulkan --depth 1 \
    && cd Real-ESRGAN-ncnn-vulkan || exit \
    && sed -i 's|git@github.com:|https://github.com/|g' .gitmodules \
    && git submodule update --init --recursive \
    && mkdir build \
    && cd build || exit \
    && cmake ../src \
    && cmake --build . -j "$(nproc)"

# FROM debian:bookworm-slim AS runner
# RUN apt-get update -y; apt-get install -y libvulkan-dev libgomp1 mesa-vulkan-drivers --no-install-recommends \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
#
# WORKDIR /app
# COPY --from=apibuilder /app/miyo .
# COPY --from=apibuilder /app/out out/
# COPY --from=webbuilder /app/dist dist/
# COPY --from=downloader /download/upscaler upscaler
#
# EXPOSE 9452
# CMD [ "/app/miyo" ]

FROM alpine:edge AS runner

# Install required packages
RUN apk update && \
    apk add --no-cache libgomp vulkan-tools mesa-vulkan-ati mesa-vulkan-intel mesa-vulkan-layers libgcc

WORKDIR /app

# Copy necessary files from other build stages
COPY --from=apibuilder /app/miyo .
COPY --from=apibuilder /app/out out/
COPY --from=webbuilder /app/dist dist/
COPY --from=compiler /app/waifu2x-ncnn-vulkan/models/. /app/waifu2x-ncnn-vulkan/build/waifu2x-ncnn-vulkan upscaler/
COPY --from=compiler /app/Real-ESRGAN-ncnn-vulkan/build/realesrgan-ncnn-vulkan upscaler/
COPY --from=downloader /download/upscaler/. upscaler/

EXPOSE 9452

CMD [ "/app/miyo" ]
