 #!/bin/bash

#diskarray=(`cat /proc/diskstats |grep -E "\bsd[a-z]\b|\bxvd[a-z]\b|\bvd[a-z]\b"|awk '{print $3}'|sort|uniq  2>/dev/null`)
#list disk include partition
#diskarray=(`cat /proc/diskstats |grep -E "sd[a-z]|xvd[a-z]|vd[a-z]"|awk '{print $3}'|sort|uniq  2>/dev/null`)
#list disk include partition
diskarray=(`cat /proc/diskstats |grep -E -w "sd[a-z]|xvd[a-z]|vd[a-z]"|awk '{print $3}'|sort|uniq  2>/dev/null`)

 

 length=${#diskarray[@]}

printf "{\n"

printf  '\t'"\"data\":["

for ((i=0;i<$length;i++))

do

        printf '\n\t\t{\n'

        printf '\t\t\t'
        printf "\"{#DEVICENAME}\":\"${diskarray[$i]}\""
        printf '\n\t\t}'

        if [ $i -lt $[$length-1] ];then

                printf ','

        fi

done

printf  "\n\t]\n"

printf "}\n"
