# Stage 1: Build the Go binary
FROM golang:1.20 AS builder

WORKDIR /app

# Copy Go source file(s)
COPY main.go .

# Optional: Initialize a Go module (only needed if you're not copying go.mod)
RUN go mod init attacker && go mod tidy

# Build the Go binary
RUN go build -o attacker main.go

# Stage 2: Create runtime image with AWS CLI and the Go binary
FROM amazon/aws-cli:2.13.5

# Copy the Go binary from builder stage
COPY --from=builder /app/attacker /usr/local/bin/attacker

# Run the Go app by default
CMD ["/usr/local/bin/attacker"]

