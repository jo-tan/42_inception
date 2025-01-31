#!/bin/sh

# Initialize database if not already done
if [ ! -d "/var/lib/mysql/mysql" ]; then
    # Initialize MariaDB data directory
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --skip-test-db

    # Start MariaDB in background
    mysqld --user=mysql --datadir=/var/lib/mysql &
    
    # Wait for MariaDB to be ready
    while ! mysqladmin ping -h'localhost' --silent; do
        sleep 1
    done

    # Create database and users with broader host permissions
    mysql -u root << EOF
    CREATE DATABASE IF NOT EXISTS ${SQL_DATABASE};
    CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';
    CREATE USER IF NOT EXISTS '${SQL_USER}'@'wordpress.inception' IDENTIFIED BY '${SQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON ${SQL_DATABASE}.* TO '${SQL_USER}'@'%';
    GRANT ALL PRIVILEGES ON ${SQL_DATABASE}.* TO '${SQL_USER}'@'wordpress.inception';
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';
    FLUSH PRIVILEGES;
EOF

    # Stop the temporary MariaDB server
    mysqladmin -u root -p${SQL_ROOT_PASSWORD} shutdown
fi

# Start MariaDB with explicit network settings
exec mysqld --user=mysql \
    --datadir=/var/lib/mysql \
    --bind-address=0.0.0.0 \
    --port=3306 \
    --skip-networking=0