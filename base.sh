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

if grep -q "ipv6.disable=1" /etc/default/grub; then
    echo "Ipv6 já foi desativado, atualizar somente o grub"
else 
    sed -i 's/^GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX=" ipv6.disable=1 /' /etc/default/grub
    update-grub
fi

install_if_not_exists ufw
ufw allow ssh
ufw allow 80
ufw allow 443
ufw --force enable

install_if_not_exists fail2ban

cat > /etc/fail2ban/jail.d/base.conf <<EOF
[sshd]
enabled = true
EOF

enable_service fail2ban

install_if_not_exists rsyslog
enable_service rsyslog

install_if_not_exists lynis
