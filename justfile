setup:
    ./setup.sh

dev-api:
    wgo -file=.go go run cmd/main.go
dev-web:
    bun --cwd web dev

build: build-web build-api
build-web:
    bun --cwd web build
build-api:
    go build -o miyo cmd/main.go

clean:
    rm -rf ./dist
    rm -rf ./miyo

install: setup build 
    mkdir -p /opt/{miyo,miyo/out}
    sudo cp -r ./upscaler /opt/miyo/upscaler
    sudo cp -r ./dist /opt/miyo/dist
    sudo cp ./miyo /opt/miyo

    # install service
    sudo cp ./miyo.service /lib/systemd/system/miyo.service
