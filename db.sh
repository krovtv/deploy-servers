#!/bin/bash
set -e

source ./lib.sh
source ./base.sh

# =========================
# MariaDB
# =========================
install_if_not_exists mariadb-server
enable_service mariadb

# =========================
# Entrada do nome do banco
# =========================
read -p "Nome do banco: " DB_NAME

# Sanitizar nome
DB_NAME=$(echo "$DB_NAME" | tr -cd '[:alnum:]_')

if [ -z "$DB_NAME" ]; then
  echo "[ERRO] Nome do banco invalido"
  exit 1
fi

# =========================
# Criar banco (se não existir)
# =========================
DB_EXISTS=$(mariadb -u root -e "SHOW DATABASES LIKE '${DB_NAME}';" | grep ${DB_NAME} || true)

if [ -z "$DB_EXISTS" ]; then
  echo "[INFO] Criando banco $DB_NAME"
  mariadb -u root -e "CREATE DATABASE \`${DB_NAME}\`;"
else
  echo "[INFO] Banco $DB_NAME ja existe"
fi

# =========================
# Gerar senha
# =========================
DB_USER_PASS=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 10)

echo "[INFO] Senha gerada para usuario $DB_NAME"

# =========================
# IPs permitidos
# =========================
IPS=("10.32.0.240" "10.32.0.252")

# =========================
# Criar usuário e grants
# =========================
for IP in "${IPS[@]}"; do
  USER_EXISTS=$(mariadb -u root -e "SELECT User FROM mysql.user WHERE User='${DB_NAME}' AND Host='${IP}';" | grep ${DB_NAME} || true)

  if [ -z "$USER_EXISTS" ]; then
    echo "[INFO] Criando usuario ${DB_NAME}@${IP}"

    mariadb -u root -e "
      CREATE USER '${DB_NAME}'@'${IP}' IDENTIFIED BY '${DB_USER_PASS}';
      GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_NAME}'@'${IP}';
    "
  else
    echo "[INFO] Usuario ${DB_NAME}@${IP} ja existe"

    mariadb -u root -e "
      GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_NAME}'@'${IP}';
    "
  fi
done

mariadb -u root -e "FLUSH PRIVILEGES;"

# =========================
# Salvar credenciais
# =========================
CRED_FILE="/root/${DB_NAME}_db.txt"

if [ ! -f "$CRED_FILE" ]; then
  echo "[INFO] Salvando credenciais em $CRED_FILE"

  cat <<EOF > $CRED_FILE
DATABASE: ${DB_NAME}
USER: ${DB_NAME}
PASSWORD: ${DB_USER_PASS}
IPS:
- 10.32.0.240
- 10.32.0.252
EOF

  chmod 600 $CRED_FILE
else
  echo "[INFO] Arquivo de credenciais ja existe: $CRED_FILE"
fi

echo "===================================="
echo "Banco configurado com sucesso:"
echo "DB: $DB_NAME"
echo "USER: $DB_NAME"
echo "IPS: 10.32.0.240, 10.32.0.252"
echo "Credenciais: $CRED_FILE"
echo "===================================="