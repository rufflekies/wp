#!/bin/bash

# Define function to print in green
echo_green() {
    echo -e "\e[32m$1\e[0m"
}

# Define function to print in white
echo_white() {
    echo -e "\e[37m$1\e[0m"
}

# Step 1: Ask for database configuration
echo_green "Step 1: Enter the database details for WordPress."
echo_green "-----------------------------------------------"
read -p "Database Name (default: wordpress): " DB_NAME
DB_NAME=${DB_NAME:-wordpress} # Default to 'wordpress' if no input

read -p "Database User (default: admin): " DB_USER
DB_USER=${DB_USER:-admin} # Default to 'admin' if no input

read -sp "Database Password (default: admin): " DB_PASSWORD
DB_PASSWORD=${DB_PASSWORD:-admin} # Default to 'admin' if no input
echo "" # Add a newline after password input

echo_green "-----------------------------------------------"
echo_green "Database Configuration:"
echo_white "Database Name: $DB_NAME"
echo_white "Database User: $DB_USER"
echo_white "Database Password: $DB_PASSWORD"
echo_green "-----------------------------------------------"

# Step 2: Update the server
echo_green "Updating server..."
sudo apt update

# Step 3: Install Apache (Skip if already installed)
if ! dpkg -l | grep -q apache2; then
    echo_green "Installing Apache..."
    sudo apt install apache2 -y
    sudo systemctl enable apache2
    sudo systemctl start apache2
else
    echo_green "Apache is already installed, skipping..."
fi

# Check Apache status
echo_green "Checking Apache status..."
systemctl status apache2

# Step 4: Install PHP and required extensions (Skip if already installed)
if ! dpkg -l | grep -q php; then
    echo_green "Installing PHP and required extensions..."
    sudo apt install -y php php-{common,mysql,xml,xmlrpc,curl,gd,imagick,cli,dev,imap,mbstring,opcache,soap,zip,intl}
else
    echo_green "PHP is already installed, skipping..."
fi

# Check PHP version
php -v

# Step 5: Install MariaDB (Skip if already installed)
if ! dpkg -l | grep -q mariadb-server; then
    echo_green "Installing MariaDB..."
    sudo apt install mariadb-server mariadb-client -y
    sudo systemctl enable --now mariadb
else
    echo_green "MariaDB is already installed, skipping..."
fi

# Step 6: Create Database and User for WordPress
echo_green "Creating WordPress database and user..."
mysql -e "CREATE DATABASE $DB_NAME DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
mysql -e "FLUSH PRIVILEGES;"

# Step 7: Download WordPress (Skip if already downloaded)
if [ ! -f "/home/rufflekies/script/latest.tar.gz" ]; then
    echo_green "Downloading WordPress..."
    cd /home/rufflekies/script && wget https://wordpress.org/latest.tar.gz
else
    echo_green "WordPress archive already downloaded, skipping..."
fi

# Step 8: Uncompress WordPress
echo_green "Uncompressing WordPress..."
tar -xvf /home/rufflekies/script/latest.tar.gz -C /home/rufflekies/script

# Step 9: Move WordPress to /var/www/wordpress (Skip if already moved)
if [ ! -d "/var/www/wordpress" ]; then
    echo_green "Moving WordPress to /var/www/wordpress..."
    sudo mv /home/rufflekies/script/wordpress /var/www/wordpress
else
    echo_green "WordPress is already in /var/www/wordpress, skipping..."
fi

# Step 10: Change ownership (Skip if already set)
if [ "$(stat -c %U /var/www/wordpress)" != "www-data" ]; then
    echo_green "Changing ownership of WordPress directory..."
    sudo chown -R www-data:www-data /var/www/wordpress/
    sudo chmod -R 755 /var/www/wordpress/
else
    echo_green "Ownership of WordPress directory is already correct, skipping..."
fi

# Step 11: Copy wp-config-sample.php to wp-config.php
echo_green "Setting up wp-config.php..."
cd /var/www/wordpress
sudo cp wp-config-sample.php wp-config.php
sudo chown www-data:www-data wp-config.php

# Step 12: Edit wp-config.php
echo_green "Editing wp-config.php..."
sudo sed -i "s/database_name_here/$DB_NAME/" wp-config.php
sudo sed -i "s/username_here/$DB_USER/" wp-config.php
sudo sed -i "s/password_here/$DB_PASSWORD/" wp-config.php
sudo sed -i "s/localhost/localhost/" wp-config.php

# Step 13: Add secure keys
echo_green "Adding secure keys to wp-config.php..."
secure_keys=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
echo "$secure_keys" | sudo tee -a wp-config.php

# Step 14: Configure Apache to load WordPress (Skip if already configured)
if [ ! -f "/etc/apache2/sites-available/wordpress.conf" ]; then
    echo_green "Configuring Apache..."
    sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/wordpress.conf
    cat > /etc/apache2/sites-available/wordpress.conf << EOF
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
else
    echo_green "Apache is already configured for WordPress, skipping..."
fi

# Enable the new site and disable the default site
echo_green "Enabling WordPress site and reloading Apache..."
sudo a2ensite wordpress.conf
sudo a2dissite 000-default.conf
sudo systemctl reload apache2

# Step 15: Get server IP address
SERVER_IP=$(hostname -I | awk '{print $1}')

# Final Step: Installation complete with database details and IP address
echo_green "Step 16: WordPress installation complete."
echo_green "-----------------------------------------------"
echo_green "Database Name: "; echo_white "$DB_NAME"
echo_green "User: "; echo_white "$DB_USER"
echo_green "Password: "; echo_white "$DB_PASSWORD"
echo_green "IP Address: "; echo_white "$SERVER_IP"
echo_green "-----------------------------------------------"
