FROM golang:1.17 AS build-env
ENV GO111MODULE on
ENV GOPROXY=https://goproxy.cn,direct
ADD . /go/src/k8s-custom-metrics-sample
ENV GOPATH /:/src/k8s-custom-metrics-sample/vendor
WORKDIR /go/src/k8s-custom-metrics-sample
RUN apt-get update -y && apt-get install gcc ca-certificates
RUN go build -o custom-metrics-sample /go/src/k8s-custom-metrics-sample


FROM alpine:3.9.6

COPY --from=build-env /go/src/k8s-custom-metrics-sample/custom-metrics-sample /
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2
COPY --from=build-env /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENV TZ "Asia/Shanghai"
RUN apk add --no-cache tzdata

RUN addgroup -g 1000 nonroot && \
    adduser -u 1000 -D -H -G nonroot nonroot && \
    chown -R nonroot:nonroot /custom-metrics-sample
USER nonroot:nonroot

ENTRYPOINT ["/custom-metrics-sample"]