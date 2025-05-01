ARG APP_OPT_ROOT=/opt/sabnzbd

# :: Util
  FROM 11notes/util AS util

# :: Build / sabnzbd
  FROM alpine AS build
  ARG APP_VERSION
  ARG APP_OPT_ROOT
  ARG BUILD_ROOT=/SABnzbd-${APP_VERSION}
  RUN set -ex; \
    apk --no-cache --update add \
      curl; \
    curl -SL https://github.com/sabnzbd/sabnzbd/releases/download/${APP_VERSION}/SABnzbd-${APP_VERSION}-src.tar.gz | tar -zxC /; \
    mkdir -p ${APP_OPT_ROOT}; \
    cp -R ${BUILD_ROOT}/* ${APP_OPT_ROOT};

# :: Header
  FROM 11notes/distroless:par2 AS par2
  FROM 11notes/distroless:unrar AS unrar
  FROM 11notes/alpine:stable

  # :: arguments
    ARG TARGETARCH
    ARG APP_IMAGE
    ARG APP_NAME
    ARG APP_VERSION
    ARG APP_ROOT
    ARG APP_UID
    ARG APP_GID
    ARG APP_OPT_ROOT

  # :: environment
    ENV APP_IMAGE=${APP_IMAGE}
    ENV APP_NAME=${APP_NAME}
    ENV APP_VERSION=${APP_VERSION}
    ENV APP_ROOT=${APP_ROOT}
    ENV APP_OPT_ROOT=${APP_OPT_ROOT}

  # :: multi-stage
    COPY --from=util /usr/local/bin /usr/local/bin
    COPY --from=build ${APP_OPT_ROOT} ${APP_OPT_ROOT}
    COPY --from=par2 /usr/local/bin /usr/local/bin
    COPY --from=unrar /usr/local/bin /usr/local/bin

# :: Run
  USER root
  RUN eleven printenv;

  # :: install application
    RUN set -ex; \
      apk --no-cache --update add \
        util-linux-misc \
        unzip \
        7zip \
        python3; \
      apk --no-cache --update --virtual .build add \
        py3-pip;

    RUN set -ex; \
      mkdir -p ${APP_ROOT}/etc; \
      pip3 install --no-cache-dir -r ${APP_OPT_ROOT}/requirements.txt --break-system-packages; \
      apk del --no-network .build;

  # :: copy filesystem changes and set correct permissions
    COPY ./rootfs /
    RUN set -ex; \
      chmod +x -R /usr/local/bin; \
      chown -R ${APP_UID}:${APP_GID} \
        ${APP_ROOT} \
        ${APP_OPT_ROOT};

# :: Volumes
  VOLUME ["${APP_ROOT}/etc"]

# :: Monitor
  HEALTHCHECK --interval=5s --timeout=2s CMD ["/usr/bin/curl", "-kILs", "--fail", "-o", "/dev/null", "http://localhost:8080"]

# :: Start
  USER ${APP_UID}:${APP_GID}