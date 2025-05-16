FROM --platform=linux/amd64 golang:1.20

WORKDIR /app
COPY main.go .

RUN go mod init attacker && go mod tidy
RUN go build -o app .

ENTRYPOINT ["./app"]

