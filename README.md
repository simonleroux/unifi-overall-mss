# STETNET Overall MSS Clamping for UniFi OS

Automatically applies `iptables` MSS clamping rule for overall on UniFi gateways. This ensures optimal TCP performance and prevents fragmentation issues across MTU-constrained VPN tunnels.

---

## ✅ Features

- 🛡️ Automatically adds MSS clamping rule
- 🔁 Runs once at boot and every N minutes (default: 5)
- 🧩 Integrates via `systemd` service and timer
- 🧼 Fully contained in `/data/STETNET/overall-mss`
- 🔄 Supports uninstall and safe re-install
- 🧠 Designed and tested for UniFi OS Version >4.3.9 on UCG ULTRA

---

## 🚀 Installation

To install with a 5-minute interval (default):

```bash
curl -fsSL https://raw.githubusercontent.com/simonleroux/unifi-overall-mss/main/install.sh | sh -s -- 5
```

Replace `5` with your desired interval in minutes.

---

## 🧼 Uninstallation

To completely remove the service, timer, and MSS rules:

```bash
curl -fsSL https://raw.githubusercontent.com/simonleroux/unifi-overall-mss/main/uninstall.sh | sh
```

---

## 🩺 Check Health

A helper script is included:

```bash
sh /data/STETNET/overall-mss/status.sh
```

This shows:
- Service & timer status
- Next timer run
- Last execution logs
- Current MSS iptables rules

---

## 🛠️ Systemd Service Controls

Manage the MSS clamping service manually:

```bash
# Start the MSS clamp script immediately
systemctl start overall-mss.service

# View current status
systemctl status overall-mss.service

# Stop the periodic timer
systemctl stop overall-mss.timer

# Restart both service and timer
systemctl restart overall-mss.service
systemctl restart overall-mss.timer
```

---

## 🔍 View MSS Rules

To see all MSS clamping rules currently applied:

```bash
iptables -t mangle -S FORWARD | grep MSS
```

---

## 🧹 Remove All MSS Rules (Manual Test)

To manually remove MSS clamping rule:

```bash
iptables -t mangle -D FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
```

> 💡 The service will reapply the rules at the next scheduled interval or can be triggered manually using `systemctl start overall-mss.service`.

---

## 📌 Notes

- IPv6 MSS clamping is not yet supported
- Rules are safely de-duplicated (checked before being added)
- The timer ensures resilience to interface changes and rule resets

---

## 📝 License

This project is licensed under the [MIT License](LICENSE).

---

## 🤝 Contributing

Contributions are welcome! Feel free to fork the repository, submit pull requests, or suggest improvements.
