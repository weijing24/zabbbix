 #!/bin/bash

redisport=(`sudo netstat -lpn|grep redis|grep tcp|awk '{print $4}'|awk -F: '{print $2}'`)
slavenum=0
portnum=${#redisport[@]}

printf "{\n"
printf  '\t'"\"data\":["
for ((i=0;i<$portnum;i++))
do
    printf '\n\t\t{\n'
    printf '\t\t\t'
    printf "\"{#REDISPORT}\":\"${redisport[$i]}\""
    printf '\n\t\t}'
    if [ $i -lt $[$portnum-1] ];then
            printf ','
    fi
done
printf  "\n\t]\n"
printf "}\n"
