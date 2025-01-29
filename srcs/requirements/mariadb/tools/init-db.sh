#!/bin/bash

# Wait for MySQL to be ready
while ! mysqladmin ping -h"localhost" --silent; do
    sleep 1
done

# Create database and user
mysql -u root -p${SQL_ROOT_PASSWORD} << EOF
CREATE DATABASE IF NOT EXISTS ${SQL_DATABASE};
CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${SQL_DATABASE}.* TO '${SQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF