#!/bin/bash
MYSQL_SECRET=$(awk '{print $NF}' /root/.mysql_secret)   #gets MySQL Password

( mysql -B -N -uroot -p${MYSQL_SECRET} -e "SELECT CONCAT('\'', user,'\'@\'', host, '\'') FROM user WHERE user != 'debian-sys-maint' AND user != 'root' AND user != ''" mysql)>mysql_users.txt ### creates a list of users # Disable after initial run so u can edit the list and thereby select wich users to export


while read line;
do
        USERS+=($line)
done < mysql_users.txt
mkdir dumps
for i in "${USERS[@]}"
do
        (mysql -B -N -uroot -p${MYSQL_SECRET} -e "SHOW GRANTS FOR $i";)
done > dumps/mysql_grants.txt

sed -i 's/$/;/' dumps/mysql_grants.txt # Semikolon am Ende jeder Zeile einfügen

################################ Create Dumps #######################################
while read dbname;
do
        dbarray+=("$dbname");
done < <(mysql -u root -p${MYSQL_SECRET} -e 'show databases;' -B)
for j in "${dbarray[@]}"
do
        mysqldump -u root -p${MYSQL_SECRET} $j >dumps/$j.dump
done
