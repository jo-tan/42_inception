#!/bin/sh

# Check if database is initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then
    # Start MariaDB in background
    mysqld --user=mysql --datadir=/var/lib/mysql &
    
    # Wait for MariaDB to be ready
    while ! mysqladmin ping -h'localhost' --silent; do
        sleep 1
    done

    # Create database and users
    mysql -u root << EOF
    CREATE DATABASE IF NOT EXISTS ${SQL_DATABASE};
    CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON ${SQL_DATABASE}.* TO '${SQL_USER}'@'%';
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}' WITH GRANT OPTION;
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${SQL_ROOT_PASSWORD}' WITH GRANT OPTION;
    FLUSH PRIVILEGES;
EOF

    # Stop the temporary MariaDB server
    mysqladmin -u root -p${SQL_ROOT_PASSWORD} shutdown
fi

# Start MariaDB in foreground
exec mysqld --user=mysql --datadir=/var/lib/mysql