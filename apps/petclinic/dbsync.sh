. /usr/local/osmosix/etc/userenv

sed -i '/\[mysqld\]/a \log_bin=mysql-bin\' /etc/my.cnf
isSlave="$cliqrAppTierName"
pass="$cliqrDatabaseRootPass"
if [ "$isSlave" == "mysql_1" ]; then
    id=1
    sed -i "/\[mysqld\]/a \server-id=${id}" /etc/my.cnf

    service mysqld restart

    mysql -u root -p$pass -e "create user 'repl'@'%' identified by '12345'"
    mysql -u root -p$pass -e "grant replication slave on *.* to 'repl'@'%' identified by '12345'"
    mysql -u root -p$pass -e "flush privileges"


    tier="mysql_2"
    tier_ip="CliqrTier_${tier}_PUBLIC_IP"
else
    id="$DEPLOYMENT_ID"
    sed -i "/\[mysqld\]/a \server-id=${id}" /etc/my.cnf

    service mysqld restart

    tier="mysql_1"
    tier_ip="CliqrTier_${tier}_PUBLIC_IP"
fi

mysql -u root -p$pass -e "stop slave"
mysql -u root -p$pass -e "CHANGE MASTER TO MASTER_HOST='${!tier_ip}', MASTER_USER='repl', MASTER_PASSWORD='12345'"
mysql -u root -p$pass -e "start slave"




