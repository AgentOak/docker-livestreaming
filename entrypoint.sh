#!/bin/sh
set -eu

if ! getent passwd app >/dev/null 2>&1; then
    addgroup -S -g "$APP_GID" app
    adduser -S -u "$APP_UID" -G app -h /var/lib/nginx -g "" -s /usr/sbin/nologin -D -H app
    mkdir -p /srv/segments/dash /srv/segments/hls /srv/segments/image /srv/recordings
    chown app: /srv/segments /srv/segments/dash /srv/segments/hls /srv/segments/image /srv/recordings
fi

if [ ! -f "/etc/nginx/nginx.conf" ]; then
    envsubst '$NGINX_WORKER_PROCESSES $NGINX_WORKER_CONNECTIONS $RTMP_MAX_CONNECTIONS $HTTP_LISTEN $RTMP_LISTEN' </etc/nginx/nginx.conf.tpl >/etc/nginx/nginx.conf
fi

# TODO: Run nginx master unprivileged
#su-exec app "$@"
exec "$@"
