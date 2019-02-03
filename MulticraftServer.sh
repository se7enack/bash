NAME="blah"
MYSQL_ROOT_PASSWORD="abcd1234"
DOMAIN="dorkcloud.com"
KEY="no"

apt-get update -y&&sudo apt-get install apache2 mysql-server -y

sed i 's/.*erverName.*/ServerName: ${NAME}/' /etc/apache2/apache2.conf

apache2ctl configtest

systemctl restart apache2

apt-get install mysql-server -y&&mysql_secure_installation

aptitude -y install expect

SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"$MYSQL\r\"
expect \"Change the root password?\"
send \"n\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")

echo "$SECURE_MYSQL"

apt-get install php libapache2-mod-php php-mcrypt php-mysql -y

sed i 's/.*irectoryIndex.*/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/' /etc/apache2/mods-enabled/dir.conf

apache2ctl configtest

systemctl restart apache2

apt-get install phpmyadmin

add-apt-repository ppa:certbot/certbot&&apt-get update&&apt-get install python-certbot-apache -y

certbot --apache -d ${DOMAIN}

cd /home&&mkdir MulticraftInstllation;cd MulticraftInstllation

wget http://www.multicraft.org/download?arch=linux$OSVer -O multicraft.tar.gz&&tar xvzf multicraft.tar.gz

cd multicraft

MULTI=$(expect -c "
set timeout 10
spawn ./setup.sh
expect \"Run each Minecraft server under its own user? (Multicraft will create system users):\"
send \"y\r\"
expect \"Run Multicraft under this user:\"
send \"minecraft\r\"
expect \"Install Multicraft in:\"
send \"/home/minecraft/multicraft\r\"
expect \"If you have a license key you can enter it now:\"
send \"$KEY\r\"
expect \"If you control multiple machines from one control panel\"
send \"y\r\"
expect \"User of the webserver:\"
send \"www-data\r\"
expect \"IP the FTP server will listen on (empty for same as daemon):\"
send \"\r\"
expect \"FTP server port:"\"
send \"21\r\"
expect \"Block FTP upload of .jar files and other executables\"
send \"y\r\"
expect \"What kind of database do you want to use?\"
send \"mysql\r\"
expect \"Ready to install Multicraft. Start installation?\"
send \"y\r\"
expect eof
")

echo "$MULTI"
