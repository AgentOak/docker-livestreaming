#!/bin/sh
set -eu

if ! getent passwd app >/dev/null 2>&1; then
    addgroup -S -g "$APP_GID" app
    adduser -S -u "$APP_UID" -G app -h /var/lib/nginx -g "" -s /usr/sbin/nologin -D -H app
fi

create_dir() {
    dirname="$1"

    if [ ! -d "$dirname" ]; then
        mkdir "$dirname"
        chown app: "$dirname"
        chmod 755 "$dirname"
    fi
}

create_dir /srv/segments
create_dir /srv/segments/dash
create_dir /srv/segments/hls
create_dir /srv/segments/image
create_dir /srv/recordings

if [ ! -f "/etc/nginx/nginx.conf" ]; then
    envsubst '$NGINX_WORKER_PROCESSES $NGINX_WORKER_CONNECTIONS $RTMP_MAX_CONNECTIONS $HTTP_LISTEN $RTMP_LISTEN' </etc/nginx/nginx.conf.tpl >/etc/nginx/nginx.conf
fi

# TODO: Run nginx master unprivileged
#su-exec app "$@"
exec "$@"
