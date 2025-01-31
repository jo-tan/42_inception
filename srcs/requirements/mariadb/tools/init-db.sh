#!/bin/sh

# Add debug output
echo "Starting MariaDB initialization..."

# Force clean initialization
rm -rf /var/lib/mysql/*
echo "Initializing MariaDB data directory..."
mysql_install_db --user=mysql --datadir=/var/lib/mysql --skip-test-db

echo "Starting temporary MariaDB server..."
# Start without password protection for initial setup
mysqld --user=mysql --datadir=/var/lib/mysql &

# Wait for MariaDB to be ready
while ! mysqladmin ping -h'localhost' --silent; do
    echo "Waiting for MariaDB to be ready..."
    sleep 1
done

echo "Creating database and users..."
# Use mysql without password for initial setup
mysql -u root << EOF
-- Set root password first
ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${SQL_DATABASE};
CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${SQL_DATABASE}.* TO '${SQL_USER}'@'%';
FLUSH PRIVILEGES;

-- Verify creation
SELECT CONCAT('Users in database after creation:') AS '';
SELECT User, Host FROM mysql.user;
EOF

echo "Shutting down temporary MariaDB server..."
# Use mysqladmin without password since we're still in initial setup
mysqladmin -u root shutdown

echo "Starting MariaDB server..."
exec mysqld --user=mysql \
    --datadir=/var/lib/mysql \
    --bind-address=0.0.0.0 \
    --port=3306 \
    --skip-networking=0