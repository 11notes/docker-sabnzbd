# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
# GLOBAL
  ARG APP_UID=1000 \
      APP_GID=1000 \
      APP_VERSION=0 \
      APP_PYTHON_VERSION=0

# APP
  ARG BUILD_ROOT=/SABnzbd-${APP_VERSION} \
      OPT_ROOT=/opt/sabnzbd

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
  FROM alpine AS source
  COPY --from=util-bin / /
  ARG APP_VERSION \
      OPT_ROOT \
      BUILD_ROOT

  RUN set -ex; \
    eleven github asset sabnzbd/sabnzbd ${APP_VERSION} SABnzbd-${APP_VERSION}-src.tar.gz; \
    mkdir -p ${OPT_ROOT}; \
    cp -R ${BUILD_ROOT}/* ${OPT_ROOT};

# :: SABNZBD
  FROM 11notes/python:${APP_PYTHON_VERSION} AS build
  USER root
  ARG OPT_ROOT \
      APP_VERSION \
      APP_ROOT \
      APP_UID \
      APP_GID \
      APP_PYTHON_VERSION

  COPY --from=source ${OPT_ROOT} ${OPT_ROOT}
  COPY ./rootfs/ /

  RUN set -ex; \
    pip install \
      uv;

  RUN set -ex; \
    uv pip install \
      --only-binary=:all: \
      -r ${OPT_ROOT}/requirements.txt;

  RUN set -ex; \
    pip uninstall -y \
      uv;

  RUN set -eux; \
    apk --update --no-cache add \
      util-linux-misc \
      unzip \
      7zip \
      coreutils \
      libstdc++;

  RUN set -ex; \
    mkdir -p ${APP_ROOT}/etc; \
    chmod +x -R /usr/local/bin; \
    chown -R ${APP_UID}:${APP_GID} \
      ${OPT_ROOT} \
      ${APP_ROOT}; \
    chmod -R 0755 ${OPT_ROOT}/*;

  RUN set -eux; \
    rm -rf \
      ${OPT_ROOT}/*.txt \
      ${OPT_ROOT}/*.html \
      ${OPT_ROOT}/*.mkd \
      ${OPT_ROOT}/linux \
      ${OPT_ROOT}/tests;

  RUN set -eux; \ 
    which pip pip3 | xargs -I {} rm -f {} || true; \
    echo $(python -c "import site; print(site.getsitepackages())")/pip | sed "s|[][']||g" | xargs -I {} rm -rf {} || true;

  RUN set -eux; \
    /usr/local/bin/python /opt/sabnzbd/SABnzbd.py --version | grep -q "${APP_VERSION}";


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

  # :: default environment
    ENV APP_IMAGE=${APP_IMAGE} \
        APP_NAME=${APP_NAME} \
        APP_VERSION=${APP_VERSION} \
        APP_ROOT=${APP_ROOT}

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