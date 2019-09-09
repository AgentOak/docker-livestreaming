load_module /usr/lib/nginx/modules/ngx_rtmp_module.so;

user app app;
pid /dev/null;

worker_processes $NGINX_WORKER_PROCESSES;

events {
    worker_connections $NGINX_WORKER_CONNECTIONS;
    multi_accept on;
}

http {
    include mime.types;
    default_type application/octet-stream;

    access_log /dev/stdout combined;
    log_not_found off;

    sendfile on;
    sendfile_max_chunk 128k;
    aio threads;
    output_buffers 2 128k;
    reset_timedout_connection on;

    server_tokens off;

    keepalive_timeout 75 65;
    keepalive_requests 10000;

    server {
        listen $HTTP_LISTEN deferred so_keepalive=on default_server;

        autoindex off;
        charset utf-8;

        expires epoch; # Sets Cache-Control: no-cache

        location = /robots.txt {
            return 200 "User-agent: *\nDisallow: /";
        }

        location /stat {
            rtmp_stat all;
        }

        # Control interface not exposed by default
        #location /control {
        #    rtmp_control all;
        #}

        location /time {
            return 200 "$time_iso8601";

            access_log off;

            # Based off of https://time.akamai.com/?iso
            default_type text/plain;
            add_header Access-Control-Allow-Origin "*" always;
            add_header Access-Control-Allow-Headers "Origin,Accept-Encoding,Referer" always;
            add_header Access-Control-Expose-Headers "Content-Length,Date" always;
            add_header Access-Control-Allow-Methods "GET,HEAD,OPTIONS" always;
        }

        location /live {
            # Should usually have the subdirectories dash/ and hls/
            alias /srv/segments;

            add_header Access-Control-Allow-Origin "*" always;
            add_header Access-Control-Expose-Headers "Content-Length,Date" always;
            add_header Access-Control-Allow-Methods "GET,HEAD,OPTIONS" always;

            # Generates lots of useless spam, do not log accesses here
            access_log off;
        }

        location /vod {
            alias /srv/recordings;

            autoindex on;

            location ~* ^/vod/(.*)\.[a-z0-9]+$ {
                # Bypass OS cache for files >4MB
                directio 4m;

                expires max;
                add_header Cache-Control "public, no-transform, immutable" always;
            }

            # TODO: Provide DASH/HLS versions using nginx-mod-http-vod
        }

        location / {
            return 404;
        }
    }
}

#rtmp_auto_push on;
#rtmp_auto_push_reconnect 1s;
#rtmp_socket_dir /run/nginx;

rtmp {
    access_log /dev/stdout;

    server {
        listen $RTMP_LISTEN;
        max_connections $RTMP_MAX_CONNECTIONS;

        chunk_size 4096;

        include applications/*.conf;
    }
}
