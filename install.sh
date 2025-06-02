#!/bin/sh
# STETNET WireGuard MSS Clamping Installer with customizable interval

WG_DIR="/data/STETNET/wg-mss"
SERVICE_NAME="wg-mss.service"
TIMER_NAME="wg-mss.timer"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"
TIMER_PATH="/etc/systemd/system/$TIMER_NAME"

INTERVAL_MIN="${1:-5}"

mkdir -p "$WG_DIR"

GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
NC="\033[0m" # No Color

echo "🔧 Writing MSS clamp script..."
cat << 'EOF' > "$WG_DIR/iptables-wg-mss.sh"
#!/bin/bash
sleep 10

wg_ifaces=$(ip -o link show | awk -F': ' '{print $2}' | grep '^wg') || true

for iface in $wg_ifaces; do
    iptables -w -t mangle -C FORWARD -o "$iface" -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu 2>/dev/null
    if [ $? -ne 0 ]; then
        iptables -w -t mangle -A FORWARD -o "$iface" -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
    fi
done

exit 0
EOF
chmod +x "$WG_DIR/iptables-wg-mss.sh"

echo "🔧 Creating systemd service..."
cat << EOF > "$WG_DIR/$SERVICE_NAME"
[Unit]
Description=STETNET: Apply MSS Clamping for WireGuard Interfaces
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=$WG_DIR/iptables-wg-mss.sh
RemainAfterExit=no

[Install]
WantedBy=multi-user.target
EOF

echo "⏲️ Creating systemd timer with $INTERVAL_MIN min interval..."
cat << EOF > "$WG_DIR/$TIMER_NAME"
[Unit]
Description=Run MSS Clamping every $INTERVAL_MIN minutes

[Timer]
OnBootSec=30
OnActiveSec=${INTERVAL_MIN}min
Unit=$SERVICE_NAME

[Install]
WantedBy=timers.target
EOF

echo "📄 Adding status.sh..."
cat << 'EOF' > "$WG_DIR/status.sh"
#!/bin/sh

GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

echo "\n🔍 ${YELLOW}STETNET WireGuard MSS Clamping Status${NC}"
echo "---------------------------------------"

echo "\n📦 Service Status:"
if systemctl is-active --quiet wg-mss.service; then
  echo "${GREEN}✅ wg-mss.service is active${NC}"
else
  echo "${RED}❌ wg-mss.service is inactive${NC}"
fi

echo "\n⏱️ Timer Status:"
if systemctl is-active --quiet wg-mss.timer; then
  echo "${GREEN}✅ wg-mss.timer is active${NC}"
else
  echo "${RED}❌ wg-mss.timer is inactive${NC}"
fi

echo "\n🗓️ Next Timer Trigger:"
systemctl list-timers --all | grep wg-mss || echo "${YELLOW}⚠️ Timer not scheduled${NC}"

echo "\n📝 Last Service Run Log:"
journalctl -u wg-mss.service --no-pager -n 5

echo "\n📡 Current MSS iptables Rules:"
iptables -t mangle -S FORWARD | grep TCPMSS || echo "${YELLOW}⚠️ No MSS clamping rules found${NC}"
EOF

chmod +x "$WG_DIR/status.sh"

ln -sf "$WG_DIR/$SERVICE_NAME" "$SERVICE_PATH"
ln -sf "$WG_DIR/$TIMER_NAME" "$TIMER_PATH"

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable "$SERVICE_NAME"
systemctl enable "$TIMER_NAME"
systemctl start "$SERVICE_NAME"
systemctl start "$TIMER_NAME"

echo ""
echo "${GREEN}✅ Installed and scheduled every $INTERVAL_MIN min.${NC}"
iptables -t mangle -S FORWARD | grep TCPMSS || echo "${YELLOW}⚠️ No MSS rules found yet.${NC}"
