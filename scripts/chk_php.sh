#!/bin/bash
exist_inner=`ip addr|grep eth1|grep inet`
if [ $? -eq 0 ];then
	HOST=`ip addr|grep eth1|grep inet|awk '{print $2}'|awk -F/ '{print $1}'`
else
	HOST=`ip addr|grep eth0|grep inet|awk '{print $2}'|awk -F/ '{print $1}'`
fi

/usr/bin/curl -s "http://$HOST/phpfpm_status?xml" 2>/dev/null| grep "<$1>" | awk -F'>|<' '{print $3}'	
