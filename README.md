# STETNET WireGuard MSS Clamping for UniFi

Automatically applies `iptables` MSS clamping rules to all `wg*` (WireGuard) interfaces on UniFi gateways. This ensures optimal TCP performance and prevents fragmentation issues across MTU-constrained VPN tunnels.

---

## ✅ Features

- 🛡️ Automatically adds MSS clamping rules to all `wg*` interfaces
- 🔁 Runs once at boot and every N minutes (default: 5)
- 🧩 Integrates via `systemd` service and timer
- 🧼 Fully contained in `/data/STETNET/wg-mss`
- 🔄 Supports uninstall and safe re-install
- 🧠 Designed for UniFi UCG Max, and similar devices

---

## 🚀 Installation

To install with a 5-minute interval (default):

```bash
curl -fsSL https://raw.githubusercontent.com/SISTF/unifi-wg-mss/main/install.sh | sh -s -- 5
```

Replace `5` with your desired interval in minutes.

---

## 🧼 Uninstallation

To completely remove the service, timer, and MSS rules:

```bash
curl -fsSL https://raw.githubusercontent.com/SISTF/unifi-wg-mss/main/uninstall.sh | sh
```

---

## 🛠️ Systemd Service Controls

Manage the MSS clamping service manually:

```bash
# Start the MSS clamp script immediately
systemctl start wg-mss.service

# View current status
systemctl status wg-mss.service

# Stop the periodic timer
systemctl stop wg-mss.timer

# Restart both service and timer
systemctl restart wg-mss.service
systemctl restart wg-mss.timer
```

---

## 🔍 View MSS Rules

To see all MSS clamping rules currently applied:

```bash
iptables -t mangle -S FORWARD | grep TCPMSS
```

---

## 🧹 Remove All MSS Rules (Manual Test)

To manually remove MSS clamping rules from all `wg*` interfaces:

```bash
for iface in $(ip -o link show | awk -F': ' '{print $2}' | grep '^wg'); do
  iptables -t mangle -D FORWARD -o "$iface" -p tcp --tcp-flags SYN,RST SYN \
    -j TCPMSS --clamp-mss-to-pmtu 2>/dev/null
done
```

> 💡 The service will reapply the rules at the next scheduled interval or can be triggered manually using `systemctl start wg-mss.service`.

---

## 📌 Notes

- IPv6 MSS clamping is not yet supported (WireGuard IPv6 is not active on UniFi)
- Only `wg*` interfaces are targeted; others are ignored
- Rules are safely de-duplicated (checked before being added)
- The timer ensures resilience to interface changes and rule resets

---

## 📝 License

This project is licensed under the [MIT License](LICENSE).

---

## 🤝 Contributing

Contributions are welcome! Feel free to fork the repository, submit pull requests, or suggest improvements.
