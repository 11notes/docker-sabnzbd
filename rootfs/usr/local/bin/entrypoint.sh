#!/bin/ash
  if [ -z "${1}" ]; then
    set -- "/usr/local/bin/python" \
      "${APP_OPT_ROOT}/SABnzbd.py" \
      --config-file ${APP_ROOT}/etc/sabnzbd.ini \
      --server "0.0.0.0" \
      --browser 0 \
      --console \
      --logging 1 \
      --disable-file-log
    eleven log start
  fi

  exec "$@"