FROM alpine:3.11

RUN apk --no-cache add icecast \
 && rm -f /etc/icecast.xml

VOLUME /etc/icecast
EXPOSE 8000

USER icecast:icecast
CMD ["icecast", "-c", "/etc/icecast/icecast.xml"]
