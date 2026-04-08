#!/bin/bash

log() {
  echo -e "[INFO] $1"
}

install_if_not_exists() {
  if dpkg -l | grep -q "^ii  $1 "; then
    echo "[INFO] $1 ja instalado"
  else
    echo "[INSTALL] Instalando $1"
    apt install -y $1
  fi
}

enable_service() {
  if systemctl is-enabled --quiet $1 2>/dev/null; then
    echo "[INFO] $1 ja habilitado"
  else
    systemctl enable $1
  fi

  if systemctl is-active --quiet $1 2>/dev/null; then
    echo "[INFO] $1 ja rodando"
  else
    systemctl start $1
  fi
}

create_file_if_not_exists() {
  FILE=$1

  if [ -f "$FILE" ]; then
    echo "[INFO] $FILE ja existe"
    return 1
  fi

  return 0
}
