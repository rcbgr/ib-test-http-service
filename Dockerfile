ARG ACCOUNT_ID
ARG REGION
ARG ENV_NAME

FROM $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/go-base-$ENV_NAME:latest as builder

RUN mkdir -p /build
WORKDIR /build
COPY main.go .
COPY go.mod .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -a -installsuffix cgo -o main main.go

RUN openssl genrsa -out server.key 2048
RUN openssl ecparam -genkey -name secp384r1 -out server.key
RUN openssl req -new -x509 -sha256 -key server.key -out server.crt -days 3650 -subj "/C=US/ST=NYC/L=NYC/O=Global Security/OU=IT Department/CN=good.com"

FROM scratch

COPY --from=builder /build/main /main
COPY --from=builder /etc/ssl/certs /etc/ssl/certs

COPY --from=builder /build/server.crt /server.crt
COPY --from=builder /build/server.key /server.key

EXPOSE 8443
CMD ["/main"]
