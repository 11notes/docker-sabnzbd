# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
# GLOBAL
  ARG APP_UID=1000 \
      APP_GID=1000 \
      APP_VERSION=0 \
      APP_OPT_ROOT=/opt/sabnzbd
  ARG BUILD_ROOT=/SABnzbd-${APP_VERSION} \
      BUILD_PYTHON=3.12

# :: FOREIGN IMAGES
  FROM 11notes/distroless:localhealth AS distroless-localhealth
  FROM 11notes/distroless:par2 AS distroless-par2
  FROM 11notes/distroless:unrar AS distroless-unrar
  FROM 11notes/util:bin AS util-bin
  FROM 11notes/util AS util


# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
# :: SOURCE
  FROM alpine AS opt
  COPY --from=util-bin / /
  ARG APP_VERSION \
      APP_OPT_ROOT \
      BUILD_ROOT

  RUN set -ex; \
    eleven github asset sabnzbd/sabnzbd ${APP_VERSION} SABnzbd-${APP_VERSION}-src.tar.gz; \
    mkdir -p ${APP_OPT_ROOT}; \
    cp -R ${BUILD_ROOT}/* ${APP_OPT_ROOT};

# :: WHEELS
  FROM 11notes/python:wheel-${BUILD_PYTHON} AS wheels
  ARG APP_OPT_ROOT
  COPY --from=opt ${APP_OPT_ROOT}/requirements.txt /requirements.txt
  USER root
  RUN set -ex; \
    mkdir -p /pip/wheels; \
    pip3 wheel \
      --wheel-dir /pip/wheels \
      -f https://11notes.github.io/python-wheels/ \
      -r /requirements.txt;

# :: SABNZBD
  FROM 11notes/python:${BUILD_PYTHON} AS build
  ARG APP_OPT_ROOT \
      APP_ROOT \
      APP_UID \
      APP_GID

  COPY --from=opt ${APP_OPT_ROOT} ${APP_OPT_ROOT}
  COPY --from=wheels /pip/wheels /pip/wheels 
  COPY ./rootfs /

  USER root

  RUN set -ex; \
    apk --no-cache --update add \
      util-linux-misc \
      unzip \
      7zip;

  RUN set -ex; \
    mkdir -p ${APP_ROOT}/etc; \
    pip3 install \
      --no-index \
      -f /pip/wheels \
      -f https://11notes.github.io/python-wheels/ \
      -r ${APP_OPT_ROOT}/requirements.txt; \
    rm -f ${APP_OPT_ROOT}/requirements.txt; \
    rm -rf /pip/wheels;

  RUN set -ex; \
    chmod +x -R /usr/local/bin; \
    chown -R ${APP_UID}:${APP_GID} \
      ${APP_ROOT};

# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
# :: HEADER
  FROM scratch

  # :: default arguments
    ARG TARGETPLATFORM \
        TARGETOS \
        TARGETARCH \
        TARGETVARIANT \
        APP_IMAGE \
        APP_NAME \
        APP_VERSION \
        APP_ROOT \
        APP_UID \
        APP_GID \
        APP_NO_CACHE

  # :: app specific arguments
    ARG APP_OPT_ROOT

  # :: default environment
    ENV APP_IMAGE=${APP_IMAGE} \
        APP_NAME=${APP_NAME} \
        APP_VERSION=${APP_VERSION} \
        APP_ROOT=${APP_ROOT}

  # :: app specific environment
    ENV APP_OPT_ROOT=${APP_OPT_ROOT}

  # :: multi-stage
    COPY --from=distroless-par2 / /
    COPY --from=distroless-unrar / /
    COPY --from=distroless-localhealth / /
    COPY --from=util / /
    COPY --from=build / /

# :: PERSISTENT DATA
  VOLUME ["${APP_ROOT}/etc"]

# :: MONITORING
  HEALTHCHECK --interval=5s --timeout=2s --start-period=5s \
    CMD ["/usr/local/bin/localhealth", "http://127.0.0.1:8080/", "-I"]

# :: EXECUTE
  USER ${APP_UID}:${APP_GID}
  ENTRYPOINT ["/usr/local/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]