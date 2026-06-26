FROM ghcr.io/home-assistant/amd64-base:3.22

ARG BUILD_VERSION
ARG BUILD_ARCH

LABEL \
  io.hass.version="${BUILD_VERSION}" \
  io.hass.type="app" \
  io.hass.arch="${BUILD_ARCH}"

RUN apk add --no-cache bash curl docker-cli jq tar coreutils

COPY run.sh /run.sh
RUN chmod 0755 /run.sh

CMD ["/run.sh"]
