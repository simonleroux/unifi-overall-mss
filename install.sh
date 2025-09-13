#!/bin/sh
# STETNET Overall MSS Clamping Installer with customizable interval

MSS_DIR="/data/STETNET/overall_mss"
SERVICE_NAME="overall_mss.service"
TIMER_NAME="overall_mss.timer"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"
TIMER_PATH="/etc/systemd/system/$TIMER_NAME"

INTERVAL_MIN="${1:-5}"

mkdir -p "$MSS_DIR"

GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
NC="\033[0m" # No Color

echo "🔧 Writing Overall MSS clamp script..."
cat << 'EOF' > "$MSS_DIR/iptables-overall-mss.sh"
#!/bin/bash
sleep 10

iptables -t mangle -C FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu 2>/dev/null
if [ $? -ne 0 ]; then
    iptables -t mangle -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
fi

exit 0
EOF
chmod +x "$MSS_DIR/iptables-overall-mss.sh"

echo "🔧 Creating systemd service..."
cat << EOF > "$MSS_DIR/$SERVICE_NAME"
[Unit]
Description=STETNET: Apply Overall MSS Clamping
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=$MSS_DIR/iptables-overall-mss.sh
RemainAfterExit=no

[Install]
WantedBy=multi-user.target
EOF

echo "⏲️ Creating systemd timer with $INTERVAL_MIN min interval..."
cat << EOF > "$MSS_DIR/$TIMER_NAME"
[Unit]
Description=Run MSS Clamping every $INTERVAL_MIN minutes

[Timer]
OnBootSec=30
OnCalendar=*:0/${INTERVAL_MIN}
Unit=$SERVICE_NAME

[Install]
WantedBy=timers.target
EOF

echo "📄 Adding status.sh..."
cat << 'EOF' > "$MSS_DIR/status.sh"
#!/bin/sh

GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

echo "\n🔍 ${YELLOW}STETNET Overall MSS Clamping Status${NC}"
echo "---------------------------------------"

echo "\n📦 Service Status:"
if systemctl is-active --quiet overall_mss.service; then
  echo "${GREEN}✅ overall_mss.service is active${NC}"
else
  echo "${YELLOW}ℹ️ overall_mss.service is currently inactive (normal)."
  echo "   It will be triggered automatically by overall_mss.timer every N minutes.${NC}"
fi

echo "\n⏱️ Timer Status:"
if systemctl is-active --quiet overall_mss.timer; then
  echo "${GREEN}✅ overall_mss.timer is active${NC}"
else
  echo "${RED}❌ overall_mss.timer is inactive${NC}"
fi

echo "\n🗓️ Next Timer Trigger:"
systemctl list-timers --all | grep overall_mss || echo "${YELLOW}⚠️ Timer not scheduled${NC}"

echo "\n📝 Last Service Run Log:"
journalctl -u overall-mss.service --no-pager -n 5

echo "\n📡 Current MSS iptables Rules:"
iptables -t mangle -S FORWARD | grep MSS || echo "${YELLOW}⚠️ No MSS clamping rules found${NC}"
EOF

chmod +x "$MSS_DIR/status.sh"

ln -sf "$MSS_DIR/$SERVICE_NAME" "$SERVICE_PATH"
ln -sf "$MSS_DIR/$TIMER_NAME" "$TIMER_PATH"

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable "$SERVICE_NAME"
systemctl enable "$TIMER_NAME"
systemctl start "$SERVICE_NAME"
systemctl start "$TIMER_NAME"

echo ""
echo "${GREEN}✅ Installed and scheduled every $INTERVAL_MIN min.${NC}"
iptables -t mangle -S FORWARD | grep MSS || echo "${YELLOW}⚠️ No MSS rules found yet.${NC}"
