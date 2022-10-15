FROM golang:1.19.2-alpine3.16 AS builder
RUN apk add --no-cache gcc musl-dev
RUN mkdir -p /api
WORKDIR /api
COPY ./ .
RUN go get -d -v ./...
CMD ["go", "run", "main.go"]
