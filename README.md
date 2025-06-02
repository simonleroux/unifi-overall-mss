# STETNET WireGuard MSS Clamping for UniFi

Automatically applies `iptables` MSS clamping rules to all `wg*` interfaces.

## ✅ Features

- Persistent MSS clamping
- Auto-runs on boot and every N minutes (default: 5)
- Fully contained in `/data/STETNET/wg-mss`
- Designed for UniFi gateways (UCG Max etc.)

## 🚀 Install

```bash
curl -fsSL https://raw.githubusercontent.com/SIESTF/unifi-wg-mss/main/install.sh | sh -s -- 5
```

## 🔄 Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/SIESTF/unifi-wg-mss/main/uninstall.sh | sh
```

## 💡 Notes

- MSS rules are applied to all `wg*` interfaces
- IPv6 support not yet included
