ARG BASE_IMAGE=debian:bookworm-slim
ARG ARCH=linux/armhf
FROM --platform=${ARCH} ${BASE_IMAGE} AS builder-base
ARG TAR=img.tar.gz
COPY ${TAR} /img.tar.gz
WORKDIR /
ARG ARCH=linux/armhf
RUN if [ "${ARCH}" = "linux/armhf" ]; then \
        mkdir -p /stage && cd /stage || exit 1; \
        tar xzf /img.tar.gz || exit 1; \
        rm /img.tar.gz; \
        echo "GMT" > /stage/etc/timezone; \
        ln -sfT /usr/share/zoneinfo/right/GMT /stage/etc/localtime; \
        exit 0; \
    fi
RUN if [ "${ARCH}" != "linux/armhf" ]; then \
       echo "This image is for Raspberry Pi Zero W only: "$(uname -m); exit 1; \
    fi

FROM scratch AS img
ENV TERM=
COPY --from=builder-base /stage /
RUN cat /etc/os-release
ENTRYPOINT ["/bin/bash"]
