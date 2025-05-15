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
echo_green "Step 1: Enter the database details for WordPress to remove."
echo_green "-----------------------------------------------"
read -p "Database Name (default: wordpress): " DB_NAME
DB_NAME=${DB_NAME:-wordpress} # Default to 'wordpress' if no input

read -p "Database User (default: admin): " DB_USER
DB_USER=${DB_USER:-admin} # Default to 'admin' if no input

echo_green "-----------------------------------------------"
echo_green "Database Configuration:"
echo_white "Database Name: $DB_NAME"
echo_white "Database User: $DB_USER"
echo_green "-----------------------------------------------"

# Step 2: Stop Apache
echo_green "Stopping Apache..."
sudo systemctl stop apache2

# Step 3: Disable WordPress site in Apache and remove WordPress configuration
echo_green "Disabling WordPress site and removing configuration..."
sudo a2dissite wordpress.conf
sudo rm /etc/apache2/sites-available/wordpress.conf

# Step 4: Enable the default Apache site (000-default.conf)
echo_green "Enabling the default Apache site (000-default.conf)..."
sudo a2ensite 000-default.conf

# Step 5: Reload Apache to apply changes
echo_green "Reloading Apache..."
sudo systemctl reload apache2

# Step 6: Remove WordPress files from /var/www/wordpress
echo_green "Removing WordPress files from /var/www/wordpress..."
sudo rm -rf /var/www/wordpress/

# Step 7: Remove WordPress database
echo_green "Removing WordPress database..."
mysql -e "DROP DATABASE IF EXISTS $DB_NAME;"
mysql -e "DROP USER IF EXISTS '$DB_USER'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Step 8: Clean up any residual configuration files
echo_green "Cleaning up residual configurations..."
sudo apt autoremove --purge -y

# Step 9: Ensure Apache service is active and running
echo_green "Ensuring Apache service is active..."
sudo systemctl start apache2
sudo systemctl enable apache2

# Step 10: Check Apache status
echo_green "Checking Apache status..."
sudo systemctl status apache2 | grep 'Active'

# Step 11: Test Apache page is loading
echo_green "Testing Apache default page..."
if curl -s http://localhost | grep -q "It works!"; then
    echo_green "Apache default page is active and loading successfully."
else
    echo_green "Apache default page is not loading. Please check Apache configuration."
fi

echo_green "-----------------------------------------------"
echo_green "WordPress removal complete!"
echo_green "-----------------------------------------------"
