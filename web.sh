#!/bin/bash
set -e

source ./lib.sh
source ./base.sh

install_if_not_exists apache2
enable_service apache2

install_if_not_exists php8.3
install_if_not_exists php8.3-fpm
install_if_not_exists php8.3-mysql
install_if_not_exists php8.3-cli
install_if_not_exists php8.3-curl
install_if_not_exists php8.3-mbstring
install_if_not_exists php8.3-zip


if create_file_if_not_exists /etc/fail2ban/jail.d/web.conf; then
  echo "[INFO] Criando configuração do Fail2Ban (web)"

cat > /etc/fail2ban/jail.d/web.conf <<EOF
[apache-auth]
enabled = true

[apache-badbots]
enabled = true

[apache-noscript]
enabled = true

[apache-overflows]
enabled = true
EOF

  systemctl restart fail2ban

else
  echo "[INFO] Fail2Ban já configurado (jail.local existente)"
fi