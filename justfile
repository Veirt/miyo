setup:
    ./setup.sh

dev-api:
    wgo -file=.go go run cmd/main.go
dev-web:
    bun --cwd web dev

build-web:
    bun --cwd web build
build-api:
    go build cmd/main.go
