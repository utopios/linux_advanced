#!/bin/bash

echo "===> [Task 1] Disabling core dumps..."

# Disable core dumps at runtime
ulimit -c 0

# Disable core dumps persistently
echo "* hard core 0" >> /etc/security/limits.conf
echo "fs.suid_dumpable = 0" >> /etc/sysctl.conf
sysctl -p

echo "Core dumps disabled."

# ==========================

echo "===> [Task 2] Securing /tmp directory..."

# Check if tmp.mount unit exists
if ! systemctl list-unit-files | grep -q tmp.mount; then
    echo "Creating systemd unit for /tmp..."
    cat > /etc/systemd/system/tmp.mount <<EOF
[Unit]
Description=Temporary Directory (/tmp)
Documentation=man:hier(7)
Before=local-fs.target

[Mount]
What=tmpfs
Where=/tmp
Type=tmpfs
Options=mode=1777,noexec,nosuid,nodev

[Install]
WantedBy=local-fs.target
EOF
    systemctl daemon-reexec
    systemctl enable tmp.mount
    systemctl start tmp.mount
else
    echo "[i] tmp.mount already exists."
fi

echo "/tmp hardened."

# ==========================

echo "===> [Task 3] Disabling unused services..."

for svc in cups avahi-daemon bluetooth; do
    if systemctl is-enabled --quiet "$svc"; then
        echo "Disabling $svc..."
        systemctl disable --now "$svc"
        systemctl mask "$svc"
    else
        echo "$svc is already disabled."
    fi
done

echo "Unused services disabled and masked."

# ==========================

echo "===> [Task 4] Hardening kernel network parameters..."

cat >> /etc/sysctl.conf <<EOF

# Hardening Network Parameters
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
EOF

sysctl -p

echo "Kernel parameters hardened."

# ==========================

echo "===> [Task 5] Disabling SSH root login and restricting users..."

# Disable root login
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config

# Restrict SSH to allowed users
if ! grep -q '^AllowUsers' /etc/ssh/sshd_config; then
    echo "AllowUsers vagrant" >> /etc/ssh/sshd_config
else
    sed -i 's/^AllowUsers.*/AllowUsers vagrant/' /etc/ssh/sshd_config
fi

systemctl reload sshd

echo "SSH root login disabled and access restricted."

# ==========================

echo "===> [Task 6] Enforcing password expiration policy..."

# Change values for default user group
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   1/' /etc/login.defs
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   7/' /etc/login.defs

# Apply to existing user
chage --maxdays 90 --mindays 1 --warndays 7 vagrant

echo "Password expiration policy enforced."

# ==========================

echo "===> [Task 7] Enforcing password complexity..."

# Backup PAM config
cp /etc/pam.d/common-password /etc/pam.d/common-password.bak

# Ensure pam_pwquality is used
sed -i '/pam_pwquality.so/d' /etc/pam.d/common-password

echo "password requisite pam_pwquality.so retry=3 minlen=12 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1" >> /etc/pam.d/common-password

echo "Password complexity enforced."

# ==========================

echo "===> [Task 8] Restricting use of 'su' command..."

# Create group if not exists
groupadd -f sugroup

# Only allow su for group
dpkg-statoverride --update --add root sugroup 4750 /bin/su

# Add user to group
usermod -aG sugroup vagrant

echo "'su' usage restricted."

# ==========================

echo "===> [Task 9] Configuring secure sudo usage..."

# Enable session logging
echo "Defaults log_output" >> /etc/sudoers
echo "Defaults!/bin/systemctl !requiretty" >> /etc/sudoers

# Allow one command without password
echo "adminuser ALL=(ALL) NOPASSWD: /sbin/reboot" >> /etc/sudoers.d/vagrant

chmod 440 /etc/sudoers.d/vagrant

echo "Sudo logging and NOPASSWD configured."

# ==========================

echo "System successfully hardened."

exit 0
