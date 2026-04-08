#!/bin/bash
set -e

source ./lib.sh
source ./base.sh

install_if_not_exists mariadb-server
enable_service mariadb

read -p "Nome do banco: " DB_NAME

DB_EXISTS=$(mariadb -u root -e "SHOW DATABASES LIKE '${DB_NAME}';" | grep ${DB_NAME} || true)

if [ -z "$DB_EXISTS" ]; then
  echo "[INFO] Criando banco $DB_NAME"
  mariadb -u root -e "CREATE DATABASE ${DB_NAME};"
else
  echo "[INFO] Banco $DB_NAME ja existe"
fi
