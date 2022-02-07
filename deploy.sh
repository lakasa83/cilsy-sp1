#!/bin/bash

#############################
##Instalasi otomatis##
##author : freddy - Jan 2022
#############################

## Cek instalasi berjalan menggunakan root  
if [ "$(id -u)" != "0" ]; then  
  echo "Script harus berjalan sebagai root" 1>&2  
  exit 1  
fi 

## Cek direktori  
pwd=$(pwd) 

## Update repo 
apt update && apt-get update -y
 echo "perbaharui repo selesai"

## Instalasi Paket
apt -y install git
apt -y install apache2
apt -y install php libapache2-mod-php libapache2-mod-php php-xml php-gd php-fpm php-curl php-mysql php-json php-opcache php-mbstring
sed -i '0,/AllowOverride\ None/! {0,/AllowOverride\ None/ s/AllowOverride\ None/AllowOverride\ All/}' /etc/apache2/apache2.conf #Allow htaccess  
apt -y install mysql-server
 echo "instalasi paket selesai"

## Start webservice
systemctl start apache2
systemctl enable apache2
systemctl start mysql
systemctl enable mysql

## Cloning repo
git clone https://github.com/sdcilsy/landing-page.git  /var/www/html/landing-page
chown -R www-data:www-data /var/www/html/landing-page
git clone https://github.com/sdcilsy/sosial-media.git /var/www/html/sosial-media
chown -R www-data:www-data /var/www/html/sosial-media
 echo "cloning selesai"

echo "============================================"
echo "WordPress Instal Script"
echo "============================================"
echo "Database Name: "
read -e dbname
echo "Database User: "
read -e dbuser
echo "Database Password: "
read -s dbpass
echo "run install? (y/n)"
read -e run
if [ "$run" == n ] ; then
exit
else
# echo "============================================"
# echo "A robot is now installing WordPress for you."
# echo "============================================"
#download wordpress
curl -O https://wordpress.org/latest.tar.gz
#unzip wordpress
tar -zxvf latest.tar.gz
rsync -av wordpress/* /var/www/html/ 
#change dir to wordpress
cd wordpress
#copy file to parent dir
cp -rf . ..
#move back to parent dir
cd ..
#remove files from wordpress folder
rm -R wordpress
#create wp config
cp wp-config-sample.php wp-config.php
#set database details with perl find and replace
perl -pi -e "s/database_name_here/$dbname/g" wp-config.php
perl -pi -e "s/username_here/$dbuser/g" wp-config.php
perl -pi -e "s/password_here/$dbpass/g" wp-config.php

#set WP salts
perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' wp-config.php

#create uploads folder and set permissions
mkdir wp-content/uploads
chmod 775 wp-content/uploads
echo "Cleaning..."
#remove zip file
rm latest.tar.gz
echo "========================="
echo "Instal selesai."
echo "========================="
fi


## Berikan izin ke direktori html
chown -R www-data:www-data /var/www/html/  
chmod -R 755 /var/www/html/ 

mysql -e "CREATE DATABASE dbsosmed;"
mysql -e "CREATE USER 'devopscilsy'@'localhost' identified by '1234567890';"
mysql -e "GRANT ALL PRIVILEGES On dbsosmed.* TO 'devopscilsy'@'localhost';" 
mysql -u devopscilsy -p dbsosmed < /var/www/html/sosial-media/dump.sql

## Restart webservice
systemctl restart apache2

 echo "Instalasi otomatis selesai"







