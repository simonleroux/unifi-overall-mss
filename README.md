# STETNET WireGuard MSS Clamping for UniFi

Automatically applies `iptables` MSS clamping rules to all `wg*` interfaces.

## ✅ Features

- Persistent MSS clamping
- Auto-runs on boot and every N minutes (default: 5)
- Fully contained in `/data/STETNET/wg-mss`
- Designed for UniFi gateways (UCG Max etc.)

## 🚀 Install

```bash
curl -fsSL https://github.com/SISTF/unifi-wg-mss/blob/1d67fb661a517c4a3315933c217ca90aa4521431/install.sh | sh -s -- 5
```

## 🔄 Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/SISTF/unifi-wg-mss/refs/heads/main/uninstall.sh | sh
```

## 💡 Notes

- MSS rules are applied to all `wg*` interfaces
- IPv6 support not yet included
