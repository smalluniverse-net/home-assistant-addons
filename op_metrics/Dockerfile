ARG BUILD_FROM
FROM $BUILD_FROM

ARG OP_VERSION BUILD_ARCH

RUN apk --update add python3 curl unzip ca-certificates && rm -rf /var/cache/apk/*

RUN cd /tmp && \
    OP_ARCH="${BUILD_ARCH//aarch64/arm64}" && \
    curl -sSLf -o op.zip "https://cache.agilebits.com/dist/1P/op2/pkg/v${OP_VERSION}/op_linux_${OP_ARCH}_v${OP_VERSION}.zip" && \
    unzip op.zip -d /tmp/op && \
    mv /tmp/op/op /usr/local/bin/op && \
    chmod +x /usr/local/bin/op && \
    rm -rf op.zip /tmp/op

COPY rootfs /
