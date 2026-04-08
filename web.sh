#!/bin/bash
set -e

source ./lib.sh
source ./base.sh

install_if_not_exists apache2
enable_service apache2

install_if_not_exists php-fpm
install_if_not_exists php-mysql
install_if_not_exists php-cli
install_if_not_exists php-curl
install_if_not_exists php-mbstring

if create_file_if_not_exists /etc/fail2ban/jail.local; then
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