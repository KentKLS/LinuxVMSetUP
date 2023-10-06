#!/usr/bin/sh

cd /var/www/html/
composer create-project laravel/laravel laravel
cd laravel
php artisan serve
cat << 'EOF' | sudo tee /etc/apache2/sites-available/laravel.conf  
<VirtualHost *:80>
DocumentRoot /var/www/html/laravel/public/
ServerName
    <Directory /var/www/html/laravel/public/>
            AllowOverride All
            Require all granted
    </Directory>
	ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF; \
a2ensite laravel.conf
systemctl reload apache2
systemctl restart apache2