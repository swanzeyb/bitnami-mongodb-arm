FROM --platform=arm64 ubuntu:20.04
LABEL maintainer "swanzeyb <swanzeyb2001@gmail.com>"

ENV HOME="/" \
    OS_ARCH="arm64" \
    OS_FLAVOUR="ubuntu-20.04" \
    OS_NAME="linux"

COPY prebuildfs /

# Add Curl
RUN apt-get update && apt-get -y install curl

# Add MongoDB Package
RUN curl --remote-name --silent --show-error --fail \
    "https://repo.mongodb.org/apt/ubuntu/dists/focal/mongodb-org/5.0/multiverse/binary-arm64/mongodb-org-server_5.0.6_arm64.deb"

RUN mkdir "/opt/bitnami/mongodb" && \
    dpkg -i --force-all --instdir="/opt/bitnami/mongodb" "mongodb-org-server_5.0.6_arm64.deb" && \
    chmod +x "/opt/bitnami/mongodb/usr/bin/mongod" && \
    rm "mongodb-org-server_5.0.6_arm64.deb"

# Ensure Dependencies are installed
RUN apt-get -y -f install

# Link mongod
RUN ln -s /opt/bitnami/mongodb/usr/bin /opt/bitnami/mongodb/bin

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
