#!/bin/sh
# STETNET WireGuard MSS Clamping Uninstaller

WG_DIR="/data/STETNET/overall-mss"
SERVICE_NAME="overall-mss.service"
TIMER_NAME="overall-mss.timer"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"
TIMER_PATH="/etc/systemd/system/$TIMER_NAME"

GREEN="\\033[1;32m"
YELLOW="\\033[1;33m"
NC="\\033[0m"

echo "🔧 Stopping and disabling systemd units..."

systemctl stop "$TIMER_NAME" 2>/dev/null
systemctl stop "$SERVICE_NAME" 2>/dev/null
systemctl disable "$TIMER_NAME" 2>/dev/null
systemctl disable "$SERVICE_NAME" 2>/dev/null

rm -f "$TIMER_PATH"
rm -f "$SERVICE_PATH"

systemctl daemon-reexec
systemctl daemon-reload

echo "🧹 Removing MSS iptables rules..."

iptables -t mangle -D FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

echo "${GREEN}✅ Uninstalled. You may delete ${YELLOW}$WG_DIR${NC} if desired."
