 #!/bin/bash

memcacheport=(`sudo netstat -lpn|grep memcache|grep tcp|awk '{print $4}'|awk -F: '{print $2}'`)
portnum=${#memcacheport[@]}

printf "{\n"
printf  '\t'"\"data\":["
for ((i=0;i<$portnum;i++))
do
    printf '\n\t\t{\n'
    printf '\t\t\t'
    printf "\"{#MEMCACHEPORT}\":\"${memcacheport[$i]}\""
    printf '\n\t\t}'
    if [ $i -lt $[$portnum-1] ];then
            printf ','
    fi
done
printf  "\n\t]\n"
printf "}\n"
