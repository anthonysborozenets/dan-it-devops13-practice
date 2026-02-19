#!/bin/bash
set -e

PRIVATE_IP="10.0.2.15"
apt-get update -y
apt-get install -y debconf-utils
apt-get install -y mysql-server
sed -i "s/^bind-address.*/bind-address = ${PRIVATE_IP}/" \
  /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql
systemctl enable mysql
mysql -uroot -proot <<EOF
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'10.0.2.%'
  IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'10.0.2.%';
FLUSH PRIVILEGES;
EOF