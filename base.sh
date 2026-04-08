#!/bin/bash
set -e

source ./lib.sh

apt update -y

install_if_not_exists curl
install_if_not_exists wget
install_if_not_exists ca-certificates
install_if_not_exists gnupg
install_if_not_exists lsb-release
install_if_not_exists htop
install_if_not_exists tree

install_if_not_exists ufw
ufw allow ssh
ufw allow 80
ufw allow 443
ufw --force enable

install_if_not_exists fail2ban

if create_file_if_not_exists /etc/fail2ban/jail.local; then
cat > /etc/fail2ban/jail.local <<EOF
[DEFAULT]
bantime = -1
findtime = 10m
maxretry = 3

[sshd]
enabled = true

[apache-auth]
enabled = true

[apache-badbots]
enabled = true

[apache-noscript]
enabled = true

[apache-overflows]
enabled = true

[mysqld-auth]
enabled = true
port = 3306
EOF
fi

enable_service fail2ban

install_if_not_exists rsyslog
enable_service rsyslog

install_if_not_exists lynis
