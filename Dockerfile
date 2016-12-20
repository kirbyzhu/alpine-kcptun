FROM frolvlad/alpine-python2
MAINTAINER leession <leession@gmail.com>
RUN apk update && apk add --no-cache tzdata bash git wget \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && pip install shadowsocks \
    && echo "Asia/Shanghai" > /etc/timezone \
    && rm -rf /tmp/* /var/cache/apk/* /root/.cache/* /root/.pip/*
EXPOSE 8388
COPY ./kcptun* entrypoint.sh /root/
ENTRYPOINT   ["/root/entrypoint.sh"]
