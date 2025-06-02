#!/bin/sh
WG_DIR="/data/STETNET/wg-mss"
SERVICE_NAME="wg-mss.service"
TIMER_NAME="wg-mss.timer"

systemctl stop "$TIMER_NAME" 2>/dev/null
systemctl stop "$SERVICE_NAME" 2>/dev/null
systemctl disable "$TIMER_NAME" 2>/dev/null
systemctl disable "$SERVICE_NAME" 2>/dev/null

rm -f "/etc/systemd/system/$TIMER_NAME"
rm -f "/etc/systemd/system/$SERVICE_NAME"

systemctl daemon-reexec
systemctl daemon-reload

wg_ifaces=$(ip -o link show | awk -F': ' '{print $2}' | grep '^wg') || true
for iface in $wg_ifaces; do
    iptables -t mangle -D FORWARD -o "$iface" -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu 2>/dev/null
done

echo "✅ Uninstalled. You may delete $WG_DIR if desired."
