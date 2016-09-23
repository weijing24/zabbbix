 #!/bin/bash

rsyncport=(`sudo netstat -tulpn|grep rsync|grep -w "0.0.0.0"|awk '{print $4}'|awk -F: '{print $2}'`)
slavenum=0
portnum=${#rsyncport[@]}

printf "{\n"
printf  '\t'"\"data\":["
for ((i=0;i<$portnum;i++))
do
    printf '\n\t\t{\n'
    printf '\t\t\t'
    printf "\"{#RSYNCPORT}\":\"${rsyncport[$i]}\""
    printf '\n\t\t}'
    if [ $i -lt $[$portnum-1] ];then
            printf ','
    fi
done
printf  "\n\t]\n"
printf "}\n"
