# Stage 1: Build the Go binary for Arm64
FROM arm64v8/golang:1.8-alpine AS builder

# Install necessary dependencies
RUN apk add --no-cache git

COPY . /go/src/github.com/kainlite/kube-image-bouncer
WORKDIR /go/src/github.com/kainlite/kube-image-bouncer

# Build the Go binary with CGO disabled for static linking
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o kube-image-bouncer

# Stage 2: Create a minimal runtime image
FROM --platform=linux/arm64 alpine

WORKDIR /app
RUN adduser -h /app -D web

# Copy the binary from the builder stage
COPY --from=builder /go/src/github.com/kainlite/kube-image-bouncer/kube-image-bouncer /app/

# Set ownership of files to the 'web' user
RUN chown -R web:web /app

USER web
ENTRYPOINT ["./kube-image-bouncer"]
EXPOSE 1323
