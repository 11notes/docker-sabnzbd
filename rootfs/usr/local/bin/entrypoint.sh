#!/bin/ash
  if [ -z "${1}" ]; then
    set -- "${APP_OPT_ROOT}/SABnzbd.py" \
      --config-file ${APP_ROOT}/etc/default.conf \
      --server "0.0.0.0"
    eleven log start
  fi

  exec "$@"