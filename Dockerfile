# Stage 1: Build the Go binary
FROM golang:1.20-alpine AS builder

WORKDIR /app

# Install git if your code imports modules from git repos (optional)
RUN apk add --no-cache git

COPY go.mod go.sum ./
RUN go mod download

COPY main.go ./

RUN go build -o attacker main.go

# Stage 2: Final image with AWS CLI and the built binary
FROM amazonlinux:2

# Install dependencies for AWS CLI and AWS CLI itself
RUN yum install -y unzip curl && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws/ && \
    yum clean all

# Copy the Go binary from builder stage
COPY --from=builder /app/attacker /usr/local/bin/attacker

# Make the binary executable
RUN chmod +x /usr/local/bin/attacker

# Run the Go binary as the container entrypoint
ENTRYPOINT ["/usr/local/bin/attacker"]

