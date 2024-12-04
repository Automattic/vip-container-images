FROM alpine:3.20.3@sha256:1e42bbe2508154c9126d48c2b8a75420c3544343bf86fd041fb7527e017a4b4a AS build

ENV SOURCE_DATE_EPOCH=0

RUN \
    apk add --no-cache gcc git musl-dev && \
    mkdir -p /target/bin && \
    echo 'int main() { return 0; }' > /true.c && \
    gcc -o /target/bin/true /true.c -Os -s -static && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /target/clientcode && \
    rm -rf /target/clientcode/.git

FROM scratch
COPY --from=build /target /
CMD ["/bin/true"]
