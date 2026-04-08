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
# Abrir o mariadb para rede interna
# =========================
echo "[INFO] Ajustando bind-address do MariaDB"

CONF_FILE="/etc/mysql/mariadb.conf.d/50-server.cnf"

if grep -q "^bind-address" $CONF_FILE; then
  sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' $CONF_FILE
  echo "[INFO] bind-address alterado para 0.0.0.0"
else
  echo "bind-address = 0.0.0.0" >> $CONF_FILE
  echo "[INFO] bind-address adicionado"
fi

systemctl restart mariadb

# =========================
# Nome do banco
# =========================
read -p "Nome do banco: " DB_NAME
DB_NAME=$(echo "$DB_NAME" | tr -cd '[:alnum:]_')

if [ -z "$DB_NAME" ]; then
  echo "[ERRO] Nome do banco invalido"
  exit 1
fi

# =========================
# Criar banco
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
# Coletar IPs manualmente
# =========================
IPS=()

echo "Digite os IPs permitidos (ENTER vazio para finalizar):"

while true; do
  read -p "IP: " IP

  [ -z "$IP" ] && break

  if [[ ! $IP =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    echo "[ERRO] IP invalido"
    continue
  fi

  if [[ " ${IPS[@]} " =~ " ${IP} " ]]; then
    echo "[INFO] IP ja informado"
    continue
  fi

  IPS+=("$IP")
done

if [ ${#IPS[@]} -eq 0 ]; then
  echo "[ERRO] Nenhum IP informado"
  exit 1
fi

echo "IPs informados:"
printf '%s
' "${IPS[@]}"

read -p "Confirmar alterações? (s/n): " CONFIRM
[ "$CONFIRM" != "s" ] && exit 0

# =========================
# Firewall (liberar IPs)
# =========================
for IP in "${IPS[@]}"; do
  ufw allow from $IP to any port 3306
done

# =========================
# IPs atuais no banco
# =========================
CURRENT_IPS=$(mariadb -u root -N -e "
SELECT Host FROM mysql.user 
WHERE User='${DB_NAME}' 
AND Host REGEXP '^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$';
")

# =========================
# Remover IPs antigos
# =========================
read -p "Deseja remover IPs antigos? (s/n): " REMOVE_OLD

if [ "$REMOVE_OLD" == "s" ]; then
  echo "[INFO] Sincronizando IPs (removendo antigos)"

  for OLD_IP in $CURRENT_IPS; do
    KEEP=false

    for NEW_IP in "${IPS[@]}"; do
      if [ "$OLD_IP" == "$NEW_IP" ]; then
        KEEP=true
        break
      fi
    done

    if [ "$KEEP" = false ]; then
      echo "[INFO] Removendo ${DB_NAME}@${OLD_IP}"
      mariadb -u root -e "DROP USER '${DB_NAME}'@'${OLD_IP}';"
    fi
  done

else
  echo "[INFO] Mantendo IPs antigos (modo append)"
fi
done

# =========================
# Criar novos acessos
# =========================
for IP in "${IPS[@]}"; do
  USER_EXISTS=$(mariadb -u root -N -e "
  SELECT 1 FROM mysql.user WHERE User='${DB_NAME}' AND Host='${IP}';
  ")

  if [ -z "$USER_EXISTS" ]; then
    echo "[INFO] Criando ${DB_NAME}@${IP}"

    mariadb -u root -e "
      CREATE USER '${DB_NAME}'@'${IP}' IDENTIFIED BY '${DB_USER_PASS}';
      GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_NAME}'@'${IP}';
    "
  else
    echo "[INFO] Usuario ${DB_NAME}@${IP} ja existe"
  fi
done

mariadb -u root -e "FLUSH PRIVILEGES;"

# =========================
# Salvar credenciais
# =========================
CRED_FILE="/root/${DB_NAME}_db.txt"

if [ ! -f "$CRED_FILE" ]; then
  cat <<EOF > $CRED_FILE
DATABASE: ${DB_NAME}
USER: ${DB_NAME}
PASSWORD: ${DB_USER_PASS}
EOF

  chmod 600 $CRED_FILE
fi

echo "===================================="
echo "Banco configurado com sucesso"
echo "DB: $DB_NAME"
echo "USER: $DB_NAME"
echo "Credenciais: $CRED_FILE"
echo "IPs liberados:"
printf '%s\n' "${IPS[@]}"

echo "===================================="
