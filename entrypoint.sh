#!/bin/bash

#set -e
export RUNENV=${RUNENV:-kcptun-ss}                        							#"RUNENV": kcptunsocks-kcptunss, kcptunsocks, kcptunss, ss
# ======= SHADOWSOCKS CONFIG ======
export SS_SERVER_ADDR=${SS_SERVER_ADDR:-"0.0.0.0"}									#"ssserveraddr": "0.0.0.0"
export SS_SERVER_PORT=${SS_SERVER_PORT:-"25"}										#"ssserverport": "25"
export SS_PASSWORD=${SS_PASSWORD:-password}											#"ssserverpw": "password"
export SS_METHOD=${SS_METHOD:-aes-256-cfb}											#"ssservermethod": "aes-256-cfb"
export SS_TIMEOUT=${SS_TIMEOUT:-300}												#"ssserveraddr": "300"
export SS_FASTOPEN=${SS_FASTOPEN:-true}												#"ssserveraddr": "true"

# ======= KCPTUNSERVER CONFIG ======
export KCPTUNSVR_LISTENPORT=${KCPTUNSVR_LISTENPORT:-"443"}							#"kcpsvrlistenport": "443",
export KCPTUNSVR_TARGETADDR=${KCPTUNSVR_TARGETADDR:-"127.0.0.1:$SS_SERVER_PORT"}	#"kcpsvrtargetaddr": "127.0.0.1:25",
export KCPTUN_KEY=${KCPTUN_KEY:-password}											#"key": "password",
export KCPTUN_MODE=${KCPTUN_MODE:-fast2}											#"mode": "fast2",
export KCPTUN_NOCOMP=${KCPTUN_NOCOMP:-false}										#"nocomp": false is compress, true is nocompress
export KCPTUN_CRYPT=${KCPTUN_CRYPT:-aes}											#"crypt": "aes",
export KCPTUN_SNDWND=${KCPTUN_SNDWND:-1024}											#"sndwnd": 1024,
export KCPTUN_RCVWND=${KCPTUN_RCVWND:-1024}											#"rcvwnd": 1024,

# ======= KCPTUNCLIENT CONFIG ======
export KCPTUNCLI_REMOTEADDR=${KCPTUNCLI_REMOTEADDR:-"127.0.0.1:$KCPTUNSVR_LISTENPORT"}				#"remoteaddr": "127.0.0.1:443",
export KCPTUNCLI_LOCALADDR=${KCPTUNCLI_LOCALADDR:-":8388"}							#"localaddr": ":8388",


if [[ "${SS_FASTOPEN}" =~ ^[Tt][Rr][Uu][Ee]|[Yy][Ee][Ss]|1|[Ee][Nn][Aa][Bb][Ll][Ee]$ ]]; then
	export SS_FASTOPEN="--fast-open"
else
	export SS_FASTOPEN=""
fi

if [[ "${KCPTUN_NOCOMP}" =~ ^[Tt][Rr][Uu][Ee]|[Yy][Ee][Ss]|1|[Ee][Nn][Aa][Bb][Ll][Ee]$ ]]; then
	export KCPTUN_NOCOMP="--nocomp"
else
	export KCPTUN_NOCOMP=""
fi


echo "env config start ..."
env
echo "env config end ..."

echo "Starting Shadowsocks ..."
nohup /usr/bin/ssserver -s "${SS_SERVER_ADDR}" -p "${SS_SERVER_PORT}" -k "${SS_PASSWORD}" -m "${SS_METHOD}" -t "${SS_TIMEOUT}" "${SS_FASTOPEN}" >/dev/null 2>&1 &
sleep 0.3
echo "ssserver (pid `pidof ssserver`)is running."
netstat -ntlup | grep ssserver

echo "Starting Kcptunsvr for Shadowsocks ..."
nohup /root/kcptun_server -l ":${KCPTUNSVR_LISTENPORT}" -t "${KCPTUNSVR_TARGETADDR}" -key "$KCPTUN_KEY" -mode "$KCPTUN_MODE" "$KCPTUN_NOCOMP" --crypt "$KCPTUN_CRYPT" --sndwnd "$KCPTUN_SNDWND" --rcvwnd "$KCPTUN_RCVWND" >/dev/null 2>&1 &
sleep 0.3
echo "kcptunsvr (pid `pidof kcptun_server`)is running."
netstat -ntlup | grep kcptun_server

echo "Starting Kcptunclient for kcptunsvr ..."
nohup /root/kcptun_client -r "$KCPTUNCLI_REMOTEADDR" -l "$KCPTUNCLI_LOCALADDR" -key "$KCPTUN_KEY" -mode "$KCPTUN_MODE" "$KCPTUN_NOCOMP" --crypt "$KCPTUN_CRYPT" --sndwnd "$KCPTUN_SNDWND" --rcvwnd "$KCPTUN_RCVWND" >/dev/null 2>&1 &
sleep 0.3
echo "kcptunclient (pid `pidof kcptun_client`)is running."
netstat -ntlup | grep kcptun_client

