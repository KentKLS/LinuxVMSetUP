
#Rewrite sources.list file to comment the first line (allowing us to apt install without issue(It's a band aid solution to a problem i didnt really get))
cat << EOF | tee /etc/apt/sources.list
#deb cdrom:[Debian GNU/Linux 12.1.0 _Bookworm_ - Official amd64 DVD Binary-1 with firmware 20230722-10:49]/ bookwor>

deb http://cdn.debian.net/debian bookworm main contrib non-free non-free-firmware
deb-src http://cdn.debian.net/debian bookworm main contrib non-free non-free-firmware

deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware

# bookworm-updates, to get updates before a point release is made;
# see https://www.debian.org/doc/manuals/debian-reference/ch02.en.html#_updates_and_backports
deb http://cdn.debian.net/debian bookworm-updates main contrib non-free non-free-firmware
deb-src http://cdn.debian.net/debian bookworm-updates main contrib non-free non-free-firmware
EOF

#Download all the packages needed for the laravel app/database/apache serv
apt install php php-curl libapache2-mod-php php-cli php-mysql php-gd php-fpm php-mbstring php-bcmath php-json php-xml php-zip php-pdo php-common adminer php-tokenizer mariadb-server -y

#Create a database for the app + user 
mysql -e "CREATE DATABASE laravel;"
mysql -e "CREATE USER 'kent'@'localhost' IDENTIFIED BY 'securepassword';"
mysql -e "GRANT ALL PRIVILEGES ON laravel.* TO 'kent'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

#Necessary step to install composer and make it usable
apt-get install curl -y
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

#Move to where app is supposed to be (apache2 thing) and create new laravel app
cd /var/www/html
composer create-project laravel/laravel laravelapp

#Give rights to file for it to work smoothly
chown -R www-data:www-data /var/www/html/laravelapp
chmod -R 775 /var/www/html/laravelapp/storage

#move to app root directory and run artisan command 
cd laravelapp/
php artisan

#Write apache2 conf file for the app we just created 
cat << EOF | tee /etc/apache2/sites-available/laravel.conf
<VirtualHost *:80>
ServerName example.com
ServerAdmin admin@example.com
DocumentRoot /var/www/html/laravelapp/public
<Directory /var/www/html/laravelapp/public>
	AllowOverride All
</Directory>
ErrorLog ${APACHE_LOG_DIR}/error.log
CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

#enable: -the conf we just wrote  -apache2 rewrite mod -adminer(mysql GUI) + Restart apache2 so that everything is taken into account
a2ensite laravel.conf
a2enmod rewrite
a2enconf adminer
systemctl restart apache2