ARG BASE_IMAGE=debian:bookworm-slim
ARG ARCH=linux/armhf
FROM --platform=${ARCH} ${BASE_IMAGE} AS builder-base
ARG TAR=img.tar.gz
COPY ${TAR} /img.tar.gz
WORKDIR /
ARG ARCH=linux/armhf
RUN if [ "${ARCH}" = "linux/armhf" ]; then \
        mkdir -p /stage && cd /stage; \
        tar xzf /img.tar.gz; \
        rm /img.tar.gz; \
        echo "GMT" > /stage/etc/timezone; \
        ln -sfT /usr/share/zoneinfo/right/GMT /stage/etc/localtime; \
        exit 0; \
    fi
RUN if [ "${ARCH}" != "linux/armhf" ]; then \
       echo "This image is for Raspberry Pi Zero W only: "$(uname -m); exit 1; \
    fi
RUN apt update && apt upgrade -y

FROM scratch AS img
ENV TERM=
COPY --from=builder-base /stage /
RUN cat /etc/os-release
