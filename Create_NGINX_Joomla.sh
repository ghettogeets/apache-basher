#!/bin/bash

#This script automatically creates a new Joomlawevsite using NGINX and php-fpm
#Maintainer: ast
#20.4.2018


function backup(){
if [ -f $1 ]
then
        local BACK="/tmp/$(basename ${1}).$(date +%F).$$"
        cp $1 $BACK
        echo "backup of $1 created at /tmp/"
else
        echo "file doesnt exist"
        return 1
fi
}

SITENAME=$1
SFTPPASSWORD=$(pwgen -s -1 -n 12)
MYSQL_SECRET=$(awk '{print $NF}' /root/.mysql_secret)

echo "the script will now run. You will be asked to provide a Password. You can pick this if you like: $SFTPPASSWORD "
groupadd $SITENAME
useradd -g $SITENAME -d /http-home/$SITENAME $SITENAME
passwd "$1"

# adding new user to sshd_config, not allowing ssh but sftp

backup /etc/ssh/sshd_config

if [ $? -eq 0 ]
then
        printf "\nMatch User ${SITENAME}\n ChrootDirectory /http-home/${SITENAME}/\n ForceCommand internal-sftp" >> /etc/ssh/sshd_config
else
        echo "could not add new user $SITENAME to /etc/ssh/sshd_config"
        exit 2
fi

if [ -d /etc/php/7.0/fpm/pool.d/ ]
then
        touch  /etc/php/7.0/fpm/pool.d/${SITENAME}.conf
        cat <<EOF > /etc/php/7.0/fpm/pool.d/${SITENAME}.conf
[${SITENAME}_pool]
user = $SITENAME
group = www-data

listen = /run/php/php7.0-fpm-${SITENAME}_pool.sock

listen.owner = www-data
listen.group = www-data
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
php_admin_value[disable_functions] = exec,passthru,shell_exec,system
php_admin_flag[allow_url_fopen] = on
chdir = /
EOF
else
        echo " directory /etc/php/7.0/fpm/pool.d/ doesnt exist"
fi

## Creating Database and DBuser
## create random password
#PASSWDDB="$(openssl rand -base64 12)"
#
## replace "-" with "_" for database username
#MAINDB=${USER_NAME//[^a-zA-Z0-9]/_}
#mysql -B -N -uroot -p${MYSQL_SECRET} -e "CREATE DATABASE $SITENAME";
#mysql -B -N -uroot -p${MYSQL_SECRET} -e "CREATE USER '${SITENAME}'@'localhost' IDENTIFIED BY '${SFTPPASSWORD}';";
#GRANT ALL ON ${SITENAME}.* TO '${SITENAME}'@'localhost';

mysql -B -N -uroot -p${MYSQL_SECRET} -e "CREATE DATABASE $SITENAME";
mysql -B -N -uroot -p${MYSQL_SECRET} -e "CREATE USER '${SITENAME}'@'localhost' IDENTIFIED BY '${SFTPPASSWORD}';";
GRANT ALL ON ${SITENAME}.* TO '${SITENAME}'@'localhost';
