#!/bin/bash

# Define function to print in green
print_green() {
    echo -e "\e[32m$1\e[0m"
}

# Update the server
print_green "Updating server..."
sudo apt update

# Install Apache
print_green "Installing Apache..."
sudo apt install apache2 -y
sudo systemctl enable apache2
sudo systemctl start apache2

# Check Apache status
print_green "Checking Apache status..."
systemctl status apache2

# Install PHP and required extensions
print_green "Installing PHP and required extensions..."
sudo apt install -y php php-{common,mysql,xml,xmlrpc,curl,gd,imagick,cli,dev,imap,mbstring,opcache,soap,zip,intl}

# Check PHP version
php -v

# Install MariaDB
print_green "Installing MariaDB..."
sudo apt install mariadb-server mariadb-client -y
sudo systemctl enable --now mariadb

# Secure MariaDB installation
print_green "Securing MariaDB installation..."
sudo mysql_secure_installation <<EOF

y
rufflekies
rufflekies
y
y
y
y
EOF

# Create Database for WordPress
print_green "Creating WordPress database..."
sudo mysql -u root -p'rufflekies' <<EOF
CREATE USER 'rufflekies'@'localhost' IDENTIFIED BY 'rufflekies';
CREATE DATABASE wordpress_db;
GRANT ALL PRIVILEGES ON wordpress_db.* TO 'rufflekies'@'localhost';
FLUSH PRIVILEGES;
EXIT;
EOF

# Download WordPress
print_green "Downloading WordPress..."
cd /tmp && wget https://wordpress.org/latest.tar.gz

# Uncompress WordPress
print_green "Uncompressing WordPress..."
tar -xvf latest.tar.gz

# Copy WordPress to web directory
print_green "Copying WordPress to /var/www/html..."
sudo cp -R wordpress /var/www/html/

# Change ownership
print_green "Changing ownership of WordPress directory..."
sudo chown -R www-data:www-data /var/www/html/wordpress/
sudo chmod -R 755 /var/www/html/wordpress/

# Copy wp-config-sample.php to wp-config.php
print_green "Setting up wp-config.php..."
cd /var/www/html/wordpress
sudo cp wp-config-sample.php wp-config.php
sudo chown www-data:www-data wp-config.php

# Edit wp-config.php
print_green "Editing wp-config.php..."
DB_NAME='wordpress_db'
DB_USER='rufflekies'
DB_PASSWORD='rufflekies'

# Add database configuration to wp-config.php
sudo sed -i "s/database_name_here/$DB_NAME/" wp-config.php
sudo sed -i "s/username_here/$DB_USER/" wp-config.php
sudo sed -i "s/password_here/$DB_PASSWORD/" wp-config.php
sudo sed -i "s/localhost/localhost/" wp-config.php

# Add secure keys
print_green "Adding secure keys to wp-config.php..."
secure_keys=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
echo "$secure_keys" | sudo tee -a wp-config.php

# Configure Apache to load WordPress
print_green "Configuring Apache..."
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/wordpress.conf
cat > /etc/apache2/sites-available/wordpress.conf << EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/wordpress

    <Directory /var/www/html/wordpress>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Enable the new site and disable the default site
print_green "Enabling WordPress site and reloading Apache..."
sudo a2ensite wordpress.conf
sudo a2dissite 000-default.conf
sudo systemctl reload apache2

print_green "WordPress installation completed successfully!"
