#!/system/bin/sh
MODDIR=${0%/*}
exec > /data/local/tmp/magisk_service_log.txt 2>&1

TIMEOUT=60
COUNTER=0
while [ "$(getprop sys.boot_completed | tr -d '\r')" != "1" ] && [ $COUNTER -lt $TIMEOUT ]; do
  sleep 1
  COUNTER=$((COUNTER + 1))
done

if [ $COUNTER -eq $TIMEOUT ]; then
  echo "Boot completed check timed out." >> /data/local/tmp/magisk_service_log.txt
  exit 1
fi

[ -d /data/tailscale ] || mkdir -p /data/tailscale

cd /data/tailscale

[ -f /data/tailscale/no-autostart ] || /system/bin/tailscaled \
  --tun userspace-networking \
  --statedir /data/tailscale \
  --socks5-server localhost:1055 \
  --outbound-http-proxy-listen localhost:1055 \
  --socket /data/tailscale/tailscaled.sock

