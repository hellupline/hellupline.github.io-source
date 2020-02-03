---
title: nginx
weight: 999
bookCollapseSection: false
bookFlatSection: false
bookToc: true

---

## run container

```bash
docker container run --rm --interactive --tty --name=stuff \
    --volume="${PWD}:/data" \
    --network="my_net" \
    --publish="8080:80" \
    --env="CONFIG_VALUE=my-app" \
    --env-file="prod.env" \
    --workdir="/data" \
    alpine
```

## build

```bash
docker build --tag my_registry/my_app:my_version --file ./Dockerfile ./
docker push my_registry/my_app:my_version

docker tag my_registry/my_app:my_version my_registry/my_app:latest
docker push my_registry/my_app:latest
```


### multi-stage dockerfile

```dockerfile
FROM golang:1.13 as build

WORKDIR /app
COPY ./ ./
RUN go build -o my_app

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /app
COPY --from=builder /app/my_app ./
CMD ["./my_app"]
```


## volumes

```bash
docker volume create my_volume
docker volume ls
docker volume rm my_volume
```


## network

```bash
docker network create my_net
docker network ls
docker network rm my_net
```


## running containers

```bash
docker container ls
docker container logs my_container
docker container exec -it my_container my_command
docker container attach my_container
```


## system

```bash
docker system events
docker system info
docker system prune --volumes --all
```


## login to aws ecr
```bash
$(aws ecr get-login --no-include-email)
```
