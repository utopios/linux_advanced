# Lab 8: Diagnose and Control a Misbehaving systemd Service

## Objective

You are managing a Linux server running a service that consumes excessive memory. Your goal is to:

* Investigate the issue using `journalctl`
* Limit the service’s memory and CPU using `systemctl set-property`
* Observe the kernel’s Out-Of-Memory (OOM) behavior
* Create log filtering via `rsyslog`
* Understand how journald and cgroups interact with systemd

---

## What the Trainer Does: Setup Script

### File: `setup_lab_service.sh`

This script:

* Creates a memory-consuming bash script
* Creates a systemd unit to run it as a service
* Starts the service
* Lets trainees take over

```bash
#!/bin/bash
# Setup script for Linux admin lab

set -e

echo "[+] Installing rsyslog if not present"
apt update && apt install -y rsyslog

echo "[+] Creating memory consumption script"
cat <<'EOF' > /usr/local/bin/memhog.sh
#!/bin/bash
buffer=()
while true; do
  buffer+=( $(head -c 1M < /dev/zero | tr '\0' 'X') )
  sleep 0.2
done
EOF

chmod +x /usr/local/bin/memhog.sh

echo "[+] Creating systemd unit for memhog.service"
cat <<EOF > /etc/systemd/system/memhog.service
[Unit]
Description=Deliberate memory abuse for training
After=network.target

[Service]
ExecStart=/usr/local/bin/memhog.sh
Restart=always
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

echo "[+] Reloading systemd and enabling service"
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable --now memhog.service

echo "Lab setup complete. Trainees can now begin the tasks."
```

---

## What Trainees Must Do

### Phase 1: Service Discovery

1. View the running service:

2. Analyze recent logs:

3. Observe memory usage using:


---

### Phase 2: Resource Control

4. Apply a hard memory limit to the service:

5. Wait for the service to exceed the limit and be killed by the kernel

---

### Phase 3: Log Analysis

6. Check logs after the kill event:

7. Inspect kernel logs for OOM kill:


---

### Phase 4 (Bonus): Log Redirection with rsyslog

8. Create a custom rsyslog rule to redirect OOM logs:

9. Restart rsyslog:

10. Re-trigger the OOM and verify:
