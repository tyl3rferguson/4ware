# Use official golang image as build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy Go module files and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the source code
COPY main.go ./

# Build the Go binary statically
RUN go build -o attacker main.go

# Use a lightweight image for the final stage
FROM alpine:latest

# Copy the binary from the builder stage
COPY --from=builder /app/attacker /usr/local/bin/attacker

# Install bash and AWS CLI (v2) for your app to run aws commands
RUN apk add --no-cache bash \
    && apk add --no-cache python3 py3-pip \
    && pip3 install awscli

# Set default command
CMD ["attacker"]

