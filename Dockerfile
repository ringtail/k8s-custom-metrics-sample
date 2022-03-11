FROM golang:1.14 AS build-env
ENV GO111MODULE on
ENV GOPROXY=https://goproxy.cn,direct
ADD . /go/src/k8s-custom-metrics-sample
ENV GOPATH /:/src/k8s-custom-metrics-sample/vendor
WORKDIR /go/src/k8s-custom-metrics-sample
RUN apt-get update -y && apt-get install gcc ca-certificates
RUN go build -o main /go/src/k8s-custom-metrics-sample


FROM alpine:3.11.6

COPY --from=build-env /go/src/k8s-custom-metrics-sample/main /
COPY --from=build-env /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENV TZ "Asia/Shanghai"
RUN apk add --no-cache tzdata
#COPY deploy/entrypoint.sh /
RUN addgroup -g 1000 nonroot && \
    adduser -u 1000 -D -H -G nonroot nonroot && \
    chown -R nonroot:nonroot /main
USER nonroot:nonroot

ENTRYPOINT ["/main"]
