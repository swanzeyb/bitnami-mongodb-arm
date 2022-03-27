FROM --platform=arm64 docker.io/bitnami/minideb:buster
LABEL maintainer "swanzeyb <swanzeyb2001@gmail.com>"

ENV HOME="/" \
    OS_ARCH="arm64" \
    OS_FLAVOUR="debian-10" \
    OS_NAME="linux"

COPY prebuildfs /
# Install required system packages and dependencies
RUN install_packages acl ca-certificates curl gzip libc6 libcom-err2 libcurl4 libffi6 libgcc1 libgcrypt20 libgmp10 libgnutls30 libgpg-error0 libgssapi-krb5-2 libhogweed4 libidn2-0 libk5crypto3 libkeyutils1 libkrb5-3 libkrb5support0 libldap-2.4-2 liblzma5 libnettle6 libnghttp2-14 libp11-kit0 libpsl5 librtmp1 libsasl2-2 libssh2-1 libssl1.1 libtasn1-6 libunistring2 numactl procps tar zlib1g

# Add MongoDB Package
WORKDIR /opt/bitnami
RUN curl --remote-name --silent --show-error --fail "https://fastdl.mongodb.org/linux/mongodb-linux-aarch64-ubuntu1804-5.0.6.tgz"
RUN mkdir "mongodb" && mkdir "mongodb/bin" && tar --directory "/opt/bitnami/mongodb/bin" --extract --gunzip --file "mongodb-linux-aarch64-ubuntu1804-5.0.6.tgz" --no-same-owner --strip-components=2
RUN rm "mongodb-linux-aarch64-ubuntu1804-5.0.6.tgz"

RUN apt-get update && apt-get upgrade -y && \
    rm -r /var/lib/apt/lists /var/cache/apt/archives
RUN chmod g+rwX /opt/bitnami

COPY rootfs /
RUN /opt/bitnami/scripts/mongodb/postunpack.sh
ENV APP_VERSION="5.0.6" \
    BITNAMI_APP_NAME="mongodb" \
    BITNAMI_IMAGE_VERSION="5.0.6-debian-10-r51" \
    PATH="/opt/bitnami/common/bin:/opt/bitnami/mongodb/bin:$PATH"

EXPOSE 27017

USER 1001
ENTRYPOINT [ "/opt/bitnami/scripts/mongodb/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/mongodb/run.sh" ]
