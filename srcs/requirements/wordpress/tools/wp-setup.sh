#!/bin/sh

# Print environment variables for debugging (remove sensitive info in production)
echo "Checking database connection..."
echo "DB_HOST: $WORDPRESS_DB_HOST"
echo "DB_NAME: $WORDPRESS_DB_NAME"
echo "DB_USER: $WORDPRESS_DB_USER"

# Use --skip-ssl flag instead of --ssl-mode=DISABLED
while ! mariadb-admin ping -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" --skip-ssl --verbose; do
    echo "Waiting for MariaDB to be ready..."
    # Try to get more specific error information
    mariadb -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" --skip-ssl -e "SELECT 1;" 2>&1
    sleep 3
done

# Check if WordPress is already configured
if [ ! -f wp-config.php ]; then
    echo "Creating wp-config.php..."
    # Create wp-config.php
    wp config create \
        --dbname="$WORDPRESS_DB_NAME" \
        --dbuser="$WORDPRESS_DB_USER" \
        --dbpass="$WORDPRESS_DB_PASSWORD" \
        --dbhost="$WORDPRESS_DB_HOST" \
        --extra-php <<PHP
define('MYSQL_CLIENT_FLAGS', MYSQLI_CLIENT_SSL_DONT_VERIFY_SERVER_CERT);
define('MYSQL_SSL_MODE', 'DISABLED');
PHP
        --allow-root

    echo "Installing WordPress core..."
    # Install WordPress
    wp core install \
        --url="https://$DOMAIN_NAME" \
        --title="$WORDPRESS_TITLE" \
        --admin_user="$WORDPRESS_ADMIN_USER" \
        --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
        --admin_email="$WORDPRESS_ADMIN_EMAIL" \
        --skip-email \
        --allow-root

    echo "Creating additional user..."
    # Create additional user if needed
    wp user create "$WORDPRESS_USER" "$WORDPRESS_USER_EMAIL" \
        --role=author \
        --user_pass="$WORDPRESS_USER_PASSWORD" \
        --allow-root

    # Install and activate Twenty Twenty theme
    echo "Installing and activating theme..."
    wp theme install twentytwenty --activate --allow-root

    # Create a test post with comments enabled
    echo "Creating sample post..."
    wp post create \
        --post_type=post \
        --post_title='Welcome to Inception' \
        --post_content='This is a test post. Feel free to leave a comment below to test the database functionality!' \
        --post_status=publish \
        --comment_status=open \
        --allow-root

    # Enable comments globally
    wp option update default_comment_status 'open' --allow-root

    # Configure permalinks
    echo "Configuring permalinks..."
    wp rewrite structure '/%postname%/' --allow-root
fi

echo "Starting PHP-FPM..."
# Start PHP-FPM
exec php-fpm