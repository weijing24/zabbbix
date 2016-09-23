#!/bin/bash

if [ $# -ne "2" ];then
	echo "arg error!"
	exit
fi
exist_inner=`ip addr|grep eth1|grep inet`
if [ $? -eq 0 ];then
	HOST=`ip addr|grep eth1|grep inet|awk '{print $2}'|awk -F/ '{print $1}'`
else
	HOST=`ip addr|grep eth0|grep inet|awk '{print $2}'|awk -F/ '{print $1}'`
fi

port="$1"
item=$2
value=`(echo "stats";sleep 0.5) | telnet $HOST $port 2>/dev/null |grep -w "STAT $item"|awk '{print $3}' `
echo "$value"
