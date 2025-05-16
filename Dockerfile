# Use official AWS CLI v2 base image (includes AWS CLI preinstalled)
FROM amazon/aws-cli:2.13.5 AS awscli

# Use official Go image to build your app
FROM golang:1.20

# Set working directory inside the container
WORKDIR /app

# Copy your Go source code into the container
COPY main.go .

# Initialize Go module and download dependencies
RUN go mod init attacker && go mod tidy

# Build the Go binary (adjust this if your main.go is part of a package)
RUN go build -o attacker main.go

# Use AWS CLI image as base for final image so aws CLI is included
FROM amazon/aws-cli:2.13.5

# Copy the built Go binary from the build stage
COPY --from=0 /app/attacker /usr/local/bin/attacker

# Set default command to run your Go app
CMD ["/usr/local/bin/attacker"]

