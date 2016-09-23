#!/bin/bash
exist_inner=`ip addr|grep eth1|grep inet`
if [ $? -eq 0 ];then
	HOST=`ip addr|grep eth1|grep inet|awk '{print $2}'|awk -F/ '{print $1}'`
else
	HOST=`ip addr|grep eth0|grep inet|awk '{print $2}'|awk -F/ '{print $1}'`
fi

#function ping {
#	/sbin/pidof nginx|wc -l
#}
#活跃的连接数量
function active() {
	/usr/bin/curl "http://$HOST/WatchNginxStatus" 2>/dev/null| grep 'Active' | awk '{print $NF}'	
}

#读取客户端的连接数
function reading() {
	/usr/bin/curl "http://$HOST/WatchNginxStatus" 2>/dev/null| grep 'Reading' | awk '{print $2}'
}

#响应数据到客户端的数量
function writing() {
	/usr/bin/curl "http://$HOST/WatchNginxStatus" 2>/dev/null| grep 'Writing' | awk '{print $4}'
}

#开启 keep-alive 的情况下,这个值等于 active – (reading+writing), 意思就是 Nginx 已经处理完正在等候下一次请求指令的驻留连接
function waiting() {
	/usr/bin/curl "http://$HOST/WatchNginxStatus" 2>/dev/null| grep 'Waiting' | awk '{print $6}'
}

#接受的连接数
function accepts() {
	/usr/bin/curl "http://$HOST/WatchNginxStatus" 2>/dev/null| awk NR==3 | awk '{print $1}'
}

#创建的握手数
function handled() {
	/usr/bin/curl "http://$HOST/WatchNginxStatus" 2>/dev/null| awk NR==3 | awk '{print $2}'
}

#处理的请求数
function requests() {
	/usr/bin/curl "http://$HOST/WatchNginxStatus" 2>/dev/null| awk NR==3 | awk '{print $3}'
}
$1
