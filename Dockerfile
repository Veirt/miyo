# Download stage for Real-ESRGAN models
FROM ubuntu:24.04 AS downloader
WORKDIR /download
ARG REALESRGAN_URL="https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-ubuntu.zip"
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    && mkdir -p upscaler \
    && wget -q "${REALESRGAN_URL}" -O upscaler/realesrgan.zip \
    && unzip -j upscaler/realesrgan.zip "*models*" -d upscaler/models-realesrgan \
    && rm -rf upscaler/*.zip

# Base compiler stage with common dependencies
FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx

FROM --platform=$BUILDPLATFORM ubuntu:24.04 AS compiler-base
RUN apt-get update -y && apt-get install -y git cmake make gcc g++

COPY --from=xx / /
ARG TARGETPLATFORM
RUN xx-apt-get install -y libvulkan-dev glslang-tools

# Compile stage for waifu2x
FROM --platform=$BUILDPLATFORM compiler-base AS waifu2x-compiler
WORKDIR /app
RUN git clone --depth 1 https://github.com/nihui/waifu2x-ncnn-vulkan.git waifu2x-ncnn-vulkan
WORKDIR /app/waifu2x-ncnn-vulkan
RUN git submodule update --init --recursive \
    && mkdir build && cd build \
    && cmake $(xx-clang --print-cmake-defines) ../src && cmake $(xx-clang --print-cmake-defines) --build . -j "$(nproc)"

# Compile stage for Real-ESRGAN
FROM --platform=$BUILDPLATFORM compiler-base AS realesrgan-compiler
WORKDIR /app
RUN git clone --depth 1 https://github.com/xinntao/Real-ESRGAN-ncnn-vulkan Real-ESRGAN-ncnn-vulkan
WORKDIR /app/Real-ESRGAN-ncnn-vulkan
RUN sed -i 's|git@github.com:|https://github.com/|g' .gitmodules \
    && git submodule update --init --recursive \
    && mkdir build && cd build \
    && cmake $(xx-clang --print-cmake-defines) ../src && cmake $(xx-clang --print-cmake-defines) --build . -j "$(nproc)"

# Build stage for web application
FROM oven/bun:1-alpine AS webbuilder
WORKDIR /app/web
COPY web/package.json web/bun.lockb ./
RUN bun install --frozen-lockfile
COPY web/ .
RUN bun run build

# Build stage for Go API
FROM golang:1.22-alpine AS apibuilder
WORKDIR /app
COPY go.* ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -a -installsuffix cgo -o miyo cmd/main.go

# Final stage
FROM ubuntu:24.04 AS runner
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgomp1 \
    vulkan-tools \
    mesa-vulkan-drivers \
    vulkan-validationlayers \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=waifu2x-compiler /app/waifu2x-ncnn-vulkan/models/. /app/waifu2x-ncnn-vulkan/build/waifu2x-ncnn-vulkan upscaler/
COPY --from=realesrgan-compiler /app/Real-ESRGAN-ncnn-vulkan/build/realesrgan-ncnn-vulkan upscaler/
COPY --from=downloader /download/upscaler/. upscaler/
COPY --from=apibuilder /app/miyo .
COPY --from=apibuilder /app/out out/
COPY --from=webbuilder /app/dist dist/
EXPOSE 9452/tcp
CMD ["/app/miyo"]
