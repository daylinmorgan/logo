FROM alpine:3.16.2

RUN apk add --no-cache inkscape

WORKDIR /data

ENTRYPOINT ["inkscape"]
