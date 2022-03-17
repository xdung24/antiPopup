# builder base
FROM golang:1.17-alpine as builder-base
RUN apk update
# install dependency here
RUN apk add build-base
RUN apk add ca-certificates && update-ca-certificates
RUN apk add git
RUN apk --no-cache add tzdata

# create ft user
ENV USER=nonrootuser
ENV UID=1000

# See https://stackoverflow.com/a/55757473/12429735RUN 
RUN adduser \    
    --disabled-password \    
    --gecos "" \    
    --home "/nonexistent" \    
    --shell "/sbin/nologin" \    
    --no-create-home \    
    --uid "${UID}" \    
    "${USER}"

# build
FROM builder-base AS builder
RUN mkdir -p /build

# copy source from local repo
#COPY . /build/ 

# clone source from remote repo
RUN git clone https://github.com/xdung24/antiPopup.git /build

# build binary
WORKDIR /build
RUN go mod download
RUN go mod verify
RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -ldflags="-w -s" -o /build/antiPopup

# release-base
FROM scratch AS release-base
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group
COPY --from=builder /usr/local/go/lib/time/zoneinfo.zip /
ENV ZONEINFO=/zoneinfo.zip

FROM release-base AS release
WORKDIR /go/bin
# copy certs from local repo
#ADD ./certs /go/bin/certs
# copy cert from remote repo
COPY --from=builder /build/certs /go/bin/
COPY --from=builder /build/antiPopup /go/bin/
USER ${USER}:${USER}
ENTRYPOINT [ "/go/bin/antiPopup" ]
