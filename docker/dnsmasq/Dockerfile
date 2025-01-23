FROM alpine:latest

WORKDIR /app
COPY . .
RUN cp dnsmasq.conf /etc/dnsmasq.conf

RUN apk add dnsmasq

CMD dnsmasq -k

