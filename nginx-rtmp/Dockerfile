FROM alpine:3

# TODO: Use fork https://github.com/sergey-dryabzhinsky/nginx-rtmp-module
RUN apk --no-cache add \
    nginx \
    nginx-mod-rtmp \
    gettext \
    ffmpeg \
    rtmpdump \
    && rm -Rf /etc/nginx

COPY ./etc/nginx /etc/nginx
COPY ./entrypoint.sh /

# These variables are necessary to properly work with bind mounts
ENV APP_UID 1000
ENV APP_GID 1000

# Configuration
ENV HTTP_LISTEN 8080
ENV RTMP_LISTEN 1935
ENV NGINX_WORKER_PROCESSES auto
ENV NGINX_WORKER_CONNECTIONS 1024
ENV RTMP_MAX_CONNECTIONS 1024

VOLUME /etc/nginx/applications /srv/recordings /srv/segments
EXPOSE 8080 1935

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off; error_log stderr info;"]
