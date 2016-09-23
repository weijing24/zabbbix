 #!/bin/bash

#list disk include partition
#mysqlport=(`netstat -pln|grep mysql|awk '{print $10}'|sed 's@[^0-9]@@g'`)

mysqlport=(`sudo netstat -lpn|grep mysql|grep tcp|awk '{print $4}'|awk -F: '{print $2}'`)
MYSQL_USER="user"
MYSQL_PASSWORD="password"
slavenum=0
portnum=${#mysqlport[@]}

printf "{\n"
printf  '\t'"\"data\":["

for ((i=0;i<$portnum;i++))
do
	if [ -S "/tmp/mysql_${mysqlport[$i]}.sock" ];then
		result=`/usr/local/mysql/bin/mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -P${mysqlport[$i]} -S/tmp/mysql_${mysqlport[$i]}.sock -e 'show slave status\G' |grep -E "Slave_IO_Running|Slave_SQL_Running"|awk '{print $2}'|grep -c Yes` 
	else
		result=`/usr/local/mysql/bin/mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -P${mysqlport[$i]} -S/tmp/mysql${mysqlport[$i]}.sock -e 'show slave status\G' |grep -E "Slave_IO_Running|Slave_SQL_Running"|awk '{print $2}'|grep -c Yes`
	fi
	if [ $result -eq 2 ];then
		slaveport[((slavenum++))]=${mysqlport[$i]}
	fi
    printf '\n\t\t{\n'
    printf '\t\t\t'
    printf "\"{#MYSQLPORT}\":\"${mysqlport[$i]}\""
    printf '\n\t\t}'
    if [ $i -lt $[$portnum-1] ];then
            printf ','
    fi
done

if [ $slavenum -ge 1 ];then
	printf ','
fi  
for ((i=0;i<$slavenum;i++))
do
	printf '\n\t\t{\n'
	printf '\t\t\t'
	printf "\"{#SLAVEPORT}\":\"${slaveport[$i]}\""
	printf '\n\t\t}'
	if [ $i -lt $[$slavenum-1] ];then
		printf ','
	fi
done

printf  "\n\t]\n"
printf "}\n"
