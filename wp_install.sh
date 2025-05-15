#!/bin/bash

# Define function to print color in green and white
echo_green() {
    echo -e "\e[32m$1\e[0m"
}
#Define white
echo_white() {
    echo -e "\e[37m$1\e[0m"
}

# Get the current script directory
SCRIPT_DIR=$(pwd)

# Step 1: Ask for database configuration
echo_green "Step 1: Enter the database details for WordPress."
echo_green "-----------------------------------------------"
read -p "Database Name (default: wordpress): " DB_NAME
DB_NAME=${DB_NAME:-wordpress}

read -p "Database User (default: admin): " DB_USER
DB_USER=${DB_USER:-admin}

read -sp "Database Password (default: admin): " DB_PASSWORD
DB_PASSWORD=${DB_PASSWORD:-admin}
echo ""

echo_green "-----------------------------------------------"
echo_green "Database Configuration:"
echo_white "Database Name: $DB_NAME"
echo_white "Database User: $DB_USER"
echo_white "Database Password: $DB_PASSWORD"
echo_green "-----------------------------------------------"

# Step 2: Update the server
echo_green "Updating server..."
sudo apt update

# Step 3: Install Apache
if ! dpkg -l | grep -q apache2; then
    echo_green "Installing Apache..."
    sudo apt install apache2 -y
    sudo systemctl enable apache2
    sudo systemctl start apache2
else
    echo_green "Apache is already installed, skipping..."
fi

# Step 4: Install PHP
if ! dpkg -l | grep -q php; then
    echo_green "Installing PHP and required extensions..."
    sudo apt install -y php php-{common,mysql,xml,xmlrpc,curl,gd,imagick,cli,dev,imap,mbstring,opcache,soap,zip,intl}
else
    echo_green "PHP is already installed, skipping..."
fi

# Step 5: Install MariaDB
if ! dpkg -l | grep -q mariadb-server; then
    echo_green "Installing MariaDB..."
    sudo apt install mariadb-server mariadb-client -y
    sudo systemctl enable --now mariadb
else
    echo_green "MariaDB is already installed, skipping..."
fi

# Step 6: Create Database and User
echo_green "Creating WordPress database and user..."
mysql -e "CREATE DATABASE $DB_NAME DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
mysql -e "FLUSH PRIVILEGES;"

# Step 7: Download WordPress
if [ ! -f "$SCRIPT_DIR/latest.tar.gz" ]; then
    echo_green "Downloading WordPress..."
    cd "$SCRIPT_DIR" && wget https://wordpress.org/latest.tar.gz
else
    echo_green "WordPress archive already downloaded, skipping..."
fi

# Step 8: Uncompress WordPress
echo_green "Uncompressing WordPress..."
tar -xvf "$SCRIPT_DIR/latest.tar.gz" -C "$SCRIPT_DIR"

# Step 9: Move WordPress
echo_green "Moving WordPress to /var/www/wordpress..."
sudo mv "$SCRIPT_DIR/wordpress" /var/www/wordpress

# Step 10: Change ownership
sudo chown -R www-data:www-data /var/www/wordpress/
sudo chmod -R 755 /var/www/wordpress/

# Step 11: Setup wp-config.php
cd /var/www/wordpress
sudo cp wp-config-sample.php wp-config.php
sudo chown www-data:www-data wp-config.php

# Step 12: Edit wp-config.php
echo_green "Editing wp-config.php..."
sudo sed -i "s/database_name_here/$DB_NAME/" wp-config.php
sudo sed -i "s/username_here/$DB_USER/" wp-config.php
sudo sed -i "s/password_here/$DB_PASSWORD/" wp-config.php

# Step 13: Add secure keys
echo_green "Adding secure keys to wp-config.php..."
secure_keys=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
echo "$secure_keys" | sudo tee -a wp-config.php

# Step 14: Configure Apache
if [ ! -f "/etc/apache2/sites-available/wordpress.conf" ]; then
    echo_green "Configuring Apache..."
    sudo tee /etc/apache2/sites-available/wordpress.conf > /dev/null << EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/wordpress
    <Directory /var/www/wordpress>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF
    sudo a2ensite wordpress.conf
    sudo a2dissite 000-default.conf
    sudo systemctl reload apache2
else
    echo_green "Apache is already configured for WordPress, skipping..."
fi

# Step 15: Get server IP address
SERVER_IP=$(hostname -I | awk '{print $1}')

echo_green "Step 16: WordPress installation complete."
echo_green "-----------------------------------------------"
echo_green "Database Name: "; echo_white "$DB_NAME"
echo_green "User: "; echo_white "$DB_USER"
echo_green "Password: "; echo_white "$DB_PASSWORD"
echo_green "IP Address: "; echo_white "$SERVER_IP"
echo_green "-----------------------------------------------"
