FROM alpine:latest
RUN apk add --no-cache curl && apk add --no-cache bash

ADD pingscript.sh /root/pingscript.sh
ENTRYPOINT ["/bin/sh", "-c"]