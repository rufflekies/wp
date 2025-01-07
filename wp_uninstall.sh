#!/bin/bash

# Define function to print in red
print_red() {
    echo -e "\e[31m$1\e[0m"
}

# Variables
DB_NAME='wordpress_db'
DB_USER='rufflekies'
APACHE_CONF='/etc/apache2/sites-available/wordpress.conf'

# Remove WordPress files
print_red "Removing WordPress files..."
sudo rm -rf /var/www/html/wordpress

# Drop the WordPress database and user
print_red "Dropping database and user..."
sudo mysql -u root -p'rufflekies' <<EOF
DROP DATABASE IF EXISTS $DB_NAME;
DROP USER IF EXISTS '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EXIT;
EOF

# Remove Apache configuration for WordPress
if [ -f "$APACHE_CONF" ]; then
    print_red "Removing Apache configuration for WordPress..."
    sudo a2dissite wordpress.conf
    sudo rm -f "$APACHE_CONF"
    sudo systemctl reload apache2
else
    print_red "Apache configuration for WordPress not found."
fi

print_red "WordPress and its database have been removed successfully!"

