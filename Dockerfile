# Build stage for web application
FROM oven/bun:1-alpine AS webbuilder
WORKDIR /app/web
COPY web/package.json web/bun.lockb ./
RUN bun install --frozen-lockfile
COPY web/ .
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}
RUN bun run build

# Build stage for Go API
FROM golang:1.22-alpine AS apibuilder
WORKDIR /app
COPY go.* ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o miyo cmd/main.go

# Download stage for Real-ESRGAN models
FROM alpine:edge AS downloader
WORKDIR /download
ARG REALESRGAN_URL="https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-ubuntu.zip"
RUN apk add --no-cache wget unzip \
    && mkdir -p upscaler \
    && wget -q "${REALESRGAN_URL}" -O upscaler/realesrgan.zip \
    && unzip -j upscaler/realesrgan.zip "*models*" -d upscaler/models-realesrgan \
    && rm -rf upscaler/*.zip

# Base compiler stage with common dependencies
FROM alpine:edge AS compiler-base
RUN apk add --no-cache git vulkan-headers vulkan-loader-dev glslang cmake make gcc g++

# Compile stage for waifu2x
FROM compiler-base AS waifu2x-compiler
WORKDIR /app
RUN git clone --depth 1 https://github.com/nihui/waifu2x-ncnn-vulkan.git waifu2x-ncnn-vulkan
WORKDIR /app/waifu2x-ncnn-vulkan
RUN git submodule update --init --recursive \
    && mkdir build && cd build \
    && cmake ../src && cmake --build . -j "$(nproc)"

# Compile stage for Real-ESRGAN
FROM compiler-base AS realesrgan-compiler
WORKDIR /app
RUN git clone --depth 1 https://github.com/xinntao/Real-ESRGAN-ncnn-vulkan Real-ESRGAN-ncnn-vulkan
WORKDIR /app/Real-ESRGAN-ncnn-vulkan
RUN sed -i 's|git@github.com:|https://github.com/|g' .gitmodules \
    && git submodule update --init --recursive \
    && mkdir build && cd build \
    && cmake ../src && cmake --build . -j "$(nproc)"

# Final stage
FROM alpine:edge AS runner
RUN apk update && apk add --no-cache libgomp vulkan-tools mesa-vulkan-ati mesa-vulkan-intel mesa-vulkan-layers libgcc
WORKDIR /app
COPY --from=apibuilder /app/miyo .
COPY --from=apibuilder /app/out out/
COPY --from=webbuilder /app/dist dist/
COPY --from=waifu2x-compiler /app/waifu2x-ncnn-vulkan/models/. /app/waifu2x-ncnn-vulkan/build/waifu2x-ncnn-vulkan upscaler/
COPY --from=realesrgan-compiler /app/Real-ESRGAN-ncnn-vulkan/build/realesrgan-ncnn-vulkan upscaler/
COPY --from=downloader /download/upscaler/. upscaler/
EXPOSE 9452
CMD ["/app/miyo"]
