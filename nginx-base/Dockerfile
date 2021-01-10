# Build environment
FROM alpine:3.12 AS builder

RUN apk add --no-cache alpine-sdk \
 && adduser build \
 && addgroup build abuild \
 && 



# Base image
FROM alpine:3.12

RUN apk add --no-cache nginx

COPY entrypoint.sh /

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
