#!/bin/bash

#ip=`ip addr|grep inet|grep -v inet6|grep -v 127.0.0.1|awk '{print $2}'|awk -F/ '{print $1}'|awk 'NR==1'`
exist_inner=`ip addr|grep eth1|grep inet`
if [ $? -eq 0 ];then
	inner_ip=`ip addr|grep eth1|grep inet|awk '{print $2}'|awk -F/ '{print $1}'`
else
	inner_ip=`ip addr|grep eth0|grep inet|awk '{print $2}'|awk -F/ '{print $1}'`
fi
sed -i -e "s/Hostname=Zabbix server/Hostname=$inner_ip/g" -e "/# ListenIP=0.0.0.0/a\ListenIP=$inner_ip" /usr/local/zabbix-2.2.13/etc/zabbix_agentd.conf
#sed -e "s/Hostname=Zabbix server/Hostname=${ip}/g" -e "/# ListenIP=0.0.0.0/a\ListenIP=$ip" zabbix_agentd.conf
