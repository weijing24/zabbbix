#!/bin/bash

if [ $# -ne "1" ];then
	echo "arg error!"
	exit -1
fi

MYSQL_PASSWORD="passwd"
MYSQL_PORT=$1
MYSQL_USER="user"

if [ -S "/tmp/mysql_$1.sock" ];then
	result=`/usr/local/mysql/bin/mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -P$1 -S/tmp/mysql_$1.sock -e 'show slave status\G' |grep -E "Slave_IO_Running|Slave_SQL_Running"|awk '{print $2}'|grep -c Yes`
else
	result=`/usr/local/mysql/bin/mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -P$1 -S/tmp/mysql$1.sock -e 'show slave status\G' |grep -E "Slave_IO_Running|Slave_SQL_Running"|awk '{print $2}'|grep -c Yes`
fi
if [ $result -eq 2 ];then
	echo $result
else
	echo 0
fi
