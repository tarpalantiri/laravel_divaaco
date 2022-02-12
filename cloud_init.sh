#!/bin/bash
apt update
apt upgrade -y
apt install php libapache2-mod-php php-mbstring php-xmlrpc php-soap php-gd php-xml php-cli php-zip php-bcmath php-tokenizer php-json php-pear mariadb-server -y
myql --user=root <<_EOF_
UPDATE mysql.user SET Password=PASSWORD('${DB_ROOT_PASSWORD}') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
_EOF_
export HOME=/root
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer
composer create-project --prefer-dist laravel/laravel ${PROJECT_NAME}
mv ${PROJECT_NAME} /var/www/html/
chgrp -R www-data /var/www/html/${PROJECT_NAME}/
chmod -R 775 /var/www/html/${PROJECT_NAME}/storage
echo "<VirtualHost *:80>
         ServerName EC2_IP_ADDRESS
         ServerAdmin webmaster@thedomain.com
         DocumentRoot /var/www/html/${PROJECT_NAME}/public

         <Directory /var/www/html/${PROJECT_NAME}>
             AllowOverride All
         </Directory>
         ErrorLog $APACHE_LOG_DIR/error.log
         CustomLog $APACHE_LOG_DIR/access.log combined
      </VirtualHost>
" >> /etc/apache2/sites-available/laravel_project.conf
a2dissite 000-default.conf
a2ensite laravel_project
a2enmod rewrite
systemctl restart apache2