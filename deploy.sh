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

## Instalasi wordpress
# rm /var/www/html/index.*  
# wget -c http://wordpress.org/latest.tar.gz  
# tar -xzvf latest.tar.gz  
# rsync -av wordpress/* /var/www/html/  
#  echo "wordpress sudah didownload"

####Download dan extract WordPress
# if test -f /tmp/latest.tar.gz
# then
# echo "WP is already downloaded."
# else
# echo "Downloading WordPress"
# cd /tmp/ && wget "http://wordpress.org/latest.tar.gz";
# fi
# /bin/tar -C $install_dir -zxf /tmp/latest.tar.gz --strip-components=1
# chown www-data: $install_dir -R

# #### Create WP-config dan set DB credentials
# /bin/mv $install_dir/wp-config-sample.php $install_dir/wp-config.php
# /bin/sed -i "s/database_name_here/$db_name/g" $install_dir/wp-config.php
# /bin/sed -i "s/username_here/$db_user/g" $install_dir/wp-config.php
# /bin/sed -i "s/password_here/$db_password/g" $install_dir/wp-config.php
# cat << EOF >> $install_dir/wp-config.php
# define('FS_METHOD', 'direct');
# EOF
# cat << EOF >> $install_dir/.htaccess
# # BEGIN WordPress
# <IfModule mod_rewrite.c>
# RewriteEngine On
# RewriteBase /
# RewriteRule ^index.php$ – [L]
# RewriteCond %{REQUEST_FILENAME} !-f
# RewriteCond %{REQUEST_FILENAME} !-d
# RewriteRule . /index.php [L]
# </IfModule>
# # END WordPress
# EOF
# chown www-data: $install_dir -R

# ##### Set WP Salts
# grep -A50 'table_prefix' $install_dir/wp-config.php > /tmp/wp-tmp-config
# /bin/sed -i '/**#@/,/$p/d' $install_dir/wp-config.php
# /usr/bin/lynx --dump -width 200 https://api.wordpress.org/secret-key/1.1/salt/ >> $install_dir/wp-config.php
# /bin/cat /tmp/wp-tmp-config >> $install_dir/wp-config.php && rm /tmp/wp-tmp-config -f
# /usr/bin/mysql -u root -e "CREATE DATABASE $db_name"
# /usr/bin/mysql -u root -e "CREATE USER '$db_name'@'localhost' IDENTIFIED WITH mysql_native_password BY '$db_password';"
# /usr/bin/mysql -u root -e "GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'localhost';"


## Berikan izin ke direktori html
chown -R www-data:www-data /var/www/html/  
chmod -R 755 /var/www/html/ 

## Instal db wordpress 
#  export DEBIAN_FRONTEND="noninteractive"  
#  debconf-set-selections <<< "mysql-server mysql-server/root_password password $db_root_password"  
#  debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $db_root_password"  


# ## akses mysql dan root password   
# read -p 'wordpress_db_name [wp_db]: ' wordpress_db_name  
# read -p 'db_root_password [only-alphanumeric]: ' db_root_password  
#  echo  "OK"

## Konfig db wordpress
# mysql -uroot -p$db_password << QUERY_INPUT
# CREATE DATABASE $db_name;  
# GRANT ALL PRIVILEGES ON $db_name.* TO 'root'@'localhost' IDENTIFIED BY 'db_password';  
# FLUSH PRIVILEGES;  
# EXIT;  
# QUERY_INPUT

## Tambah db credentias in wordpress  
# cd /var/www/html/  
# sudo mv wp-config-sample.php wp-config.php  
# perl -pi -e "s/database_name_here/$wordpress_db_name/g" wp-config.php  
# perl -pi -e "s/username_here/root/g" wp-config.php  
# perl -pi -e "s/password_here/$db_root_password/g" wp-config.php  

## DB variable sosial-media pesbuk
# mysql -e "CREATE USER $db_user;"
# mysql -e "GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'localhost' IDENTIFIED BY '$db_pass';"
# mysql -e "FLUSH PRIVILEGES;"
# mysql -u devopscilsy -p dbsosmed < /var/www/html/sosial-media/dump.sql

mysql -e "CREATE DATABASE dbsosmed;"
mysql -e "CREATE USER 'devopscilsy'@'localhost' identified by '1234567890';"
mysql -e "GRANT ALL PRIVILEGES On dbsosmed.* TO 'devopscilsy'@'localhost';" 
mysql -u devopscilsy -p dbsosmed < /var/www/html/sosial-media/dump.sql

## Restart webservice
systemctl restart apache2

 echo "Instalasi otomatis selesai"







