# syntax=docker/dockerfile:1.4
ARG GOVERSION=1.20

FROM --platform=${BUILDPLATFORM} golang:${GOVERSION} AS build

# These two are automatically set by docker buildx
ARG TARGETARCH
ARG TARGETOS

WORKDIR /src
# COPY --link go.mod go.sum ./
# ARG GOPRIVATE=github.com/defang-io/defang-mvp
# RUN go mod download

ARG GOSRC=./secrets.go
COPY --link ${GOSRC} ./
ARG BUILD=./secrets.go
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -trimpath -buildvcs=false -ldflags="-w -s" -o /secrets ${BUILD}

# RUN go test -v ./...


FROM --platform=${TARGETPLATFORM} scratch

COPY --link --from=build /secrets /secrets
ENTRYPOINT [ "/secrets" ]
VOLUME [ "/run/secrets" ]
