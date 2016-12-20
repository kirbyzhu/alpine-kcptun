ENV VERSION 20161202
FROM frolvlad/alpine-python2
MAINTAINER leession <leession@gmail.com>
RUN apk update && apk add --no-cache tzdata bash git wget \
	&& wget https://github.com/leession/alpine-kcptun/raw/master/entrypoint.sh -O /root/entrypoint.sh \
	&& wget https://github.com/xtaci/kcptun/releases/download/v"$VERSION"/kcptun-linux-amd64-"$VERSION".tar.gz \
		-O kcptun_$version.tar.gz \
		&& tar -zxvf kcptun_"$VERSION".tar.gz \
		&& cp client_linux_amd64 /root/kcptun_client \
		&& cp server_linux_amd64 /root/kcptun_server \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && pip install shadowsocks \
    && echo "Asia/Shanghai" > /etc/timezone \
    && rm -rf /tmp/* /var/cache/apk/* /root/.cache/* /root/.pip/*
EXPOSE 8388
ENTRYPOINT   ["/root/entrypoint.sh"]
