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
    # Change the role to 'author' to see clear differences
    wp user create "$WORDPRESS_USER" "$WORDPRESS_USER_EMAIL" \
        --role=author \
        --user_pass="$WORDPRESS_USER_PASSWORD" \
        --allow-root

    # Install and activate a more colorful theme
    echo "Installing and activating colorful theme..."
    wp theme install inspiro --activate --allow-root

    # Create demo posts with images
    echo "Creating admin post..."
    wp post create \
        --post_type=post \
        --post_title='🚀 Welcome to Inception!' \
        --post_content='<h2>👋 Hello Docker Enthusiasts!</h2>
        <p>This post is created by the admin. Feel free to explore and leave comments below!</p>
        <h3>✨ Key Features:</h3>
        <ul>
            <li>🔒 Secure HTTPS connection</li>
            <li>🗄️ MariaDB database</li>
            <li>⚡ Nginx web server</li>
            <li>🐳 Docker containerization</li>
        </ul>' \
        --post_status=publish \
        --post_author=$WORDPRESS_ADMIN_USER \
        --comment_status=open \
        --allow-root

    echo "Creating author post..."
    wp post create \
        --post_type=post \
        --post_title='🎨 Author Post - Exploring User Roles' \
        --post_content='<h2>🔍 Testing Different User Permissions</h2>
        <p>This post is created by an author user. Notice the different capabilities between admin and author roles!</p>
        <h3>📝 Author Can:</h3>
        <ul>
            <li>✅ Create new posts</li>
            <li>✅ Upload media</li>
            <li>✅ Moderate comments on their posts</li>
        </ul>
        <h3>❌ Author Cannot:</h3>
        <ul>
            <li>Install themes or plugins</li>
            <li>Modify other users posts</li>
            <li>Change site settings</li>
        </ul>' \
        --post_status=publish \
        --post_author=$WORDPRESS_USER \
        --comment_status=open \
        --allow-root

    # Enable comments globally
    wp option update default_comment_status 'open' --allow-root

    # Configure permalinks
    echo "Configuring permalinks..."
    wp rewrite structure '/%postname%/' --allow-root

    # Set up some theme customization
    wp option update blogdescription "A Docker-powered WordPress Site" --allow-root
fi

echo "Starting PHP-FPM..."
# Start PHP-FPM
exec php-fpm