#!/bin/bash
#check disk is raid or not
#check disk error or fine

PATH=$PATH:/sbin:/usr/sbin/
is_raid=1   #check disk is raid or not
is_health=1 #check disk is health or not
alarm_num=50 #media error threshold
if [ -e /usr/local/perl/bin/perl ];then
    PERL=/usr/local/perl/bin/perl;
else 
    PERL=/usr/bin/perl
fi

if [ -e /opt/MegaRAID/MegaCli/MegaCli64 ]; then
     MEGACLI=/opt/MegaRAID/MegaCli/MegaCli64
else
     MEGACLI=/usr/sbin/MegaCli
fi

#if not lspci or dmidecode
if ! which lspci  >/dev/null ;then
    echo "not lspci"
    exit 2
    fi
if ! which dmidecode  >/dev/null ;then
    echo "not dmidecode"
    exit 2
    fi

#get ip address
ip_address=$(/sbin/ifconfig eth0 |$PERL -ne '{if(m#(?<=inet addr:)[^\s]+#){print "$&"}}')

#check disk is raid or not

#Dell2850|1850
m_num=$(dmidecode -t system | grep "Product Name"|grep -i PowerEdge|awk '{print $4}')
if [ x"${m_num}" != x"" ];then
if [ x"${m_num}" == x"1850" ] || [ x"${m_num}" == x"2850" ];then
    is_raid=0
fi
fi

if lspci | grep -i RAID >/dev/null;then
    is_raid=1
elif which lspci >/dev/null;then
    is_raid=0
fi

#check machine type

machine_type=$(dmidecode -t system | grep "Product Name"|head -n 1|$PERL -ne '{m#(?<=:\s)\w+(?=\s+)#;print "$&\n"}')


if [ x"$machine_type" == x"PowerEdge" ];then
    machine="DELL"
elif [ x"$machine_type" == x"ProLiant" ];then
    machine="HP"
elif echo $machine_type|grep -i IBM >/dev/null;then
    machine="IBM"
fi

if [ x"$is_raid" == x"1" ];then
if [ x"$machine" == x"DELL" ] || [ x"$machine" == x"IBM" ];then
    controller_count=$(($($MEGACLI -adpCount |grep "Controller Count"|wc -l) -1))
    for controller in $(seq 0 $controller_count)
    do
    if $MEGACLI -AdpAllInfo -a${controller} |grep -i degraded|grep -v 0 >/dev/null;then
        is_health=0
        error=${error}"The raid controller ${controller} is degraded\n";
    fi
    if $MEGACLI -AdpAllInfo -a${controller} |grep -i "Failed Disks"|grep -v 0 >/dev/null;then
        is_health=0
        error=${error}"The raid controller ${controller} has Failed Disks\n";
    fi
    if $MEGACLI -PDlist -aAll|grep -i Firm |grep -i offline >/dev/null;then
        is_health=0
        error=${error}"The raid controller ${controller} is offline\n";
    fi
    pd_count=$($MEGACLI -PDGetNum -a${controller}|grep ':'|awk '{print $NF}' | head -1)
    pda_count=$($MEGACLI -PDlist -a${controller}|grep -P 'Enclosure Number|Slot Number'|sed -e 'N;s/\n/ /'|wc -l)
    if [ $pd_count -lt $pda_count ];then
        backplan=1
    fi
    for pd in $($MEGACLI -PDlist -a${controller}|grep -P 'Enclosure Number|Slot Number'|sed -e 'N;s/\n/ /'|$PERL -ne '{m#Enclosure Number:\s+(\d+)\s+Slot Number:\s+(\d+)#;print "$1:$2\n"}'|grep -v 255|xargs|$PERL -pe '{s#\s+$##}')
    do
    if $MEGACLI -pdInfo -PhysDrv[$pd] -a${controller}|grep "Media Error Count"|grep -v ': 0' >/dev/null;then
        num=$($MEGACLI -pdInfo -PhysDrv[$pd] -a${controller}|grep "Media Error Count"|awk '{print $NF}')
    if [ $num -gt $alarm_num ];then
        is_health=0
        device_id=$($MEGACLI -pdInfo -PhysDrv[$pd] -a${controller}|grep 'Device Id:'|awk '{print $NF}')
        error=${error}"The controller ${controller} Device Id ${device_id} has Media Error count ${num}\n";
    fi
    fi
    done
    if [ x"$backplan" == x"1" ];then
        if $MEGACLI -PDlist -a${controller}|grep -B14 BACKPLANE|grep "Media Error Count"|grep -v ': 0' >/dev/null;then
        num=$($MEGACLI -PDlist -a${controller}|grep -B14 BACKPLANE|grep "Media Error Count"|awk '{print $NF}')
    if [ $num -gt $alarm_num ];then
        is_health=0
        device_id=$($MEGACLI -PDlist -a${controller}|grep -B14 BACKPLANE|grep 'Device Id:'|awk '{print $NF}')
        error=${error}"The controller ${controller} BACKPLANE Device Id ${device_id} has Media Error count ${num}\n";
        fi
fi
    fi
    done
elif [ x"$machine" == x"HP" ];then
     for slot in $(hpacucli controller all show detail |grep -P  'Slot: \d+'|awk '{print $2}'|xargs|$PERL -pe '{s#\s+$##}')
     do
     if hpacucli ctrl slot=${slot} show detail config|grep -i "Controller Status" |grep -v -i 'ok' >/dev/null ;then
         is_health=0
         error=${error}"The raid Controller slot ${slot} Controller Status is not ok\n";
     fi
     for phd in $(hpacucli ctrl slot=${slot} show detail config|grep physicaldrive|awk '{print $NF}'|xargs|$PERL -pe '{s#\s+$##}')
     do
         if hpacucli controller slot=${slot} physicaldrive $phd show detail|grep -i status|grep -v -i 'ok' >/dev/null;then
         is_health=0
         error=${error}"slot ${slot} physicaldrive $phd  is not ok\n";
         fi
     done
     done
fi
else
for disk in $(df -TH |grep [sh]d|awk '{print $1}')
do
if smartctl -H $disk|grep Health|grep Status|grep -v -i ok >/dev/null;then
is_health=0
error=${error}"$disk health status is not ok\n"
fi
done
fi
if [ $is_health -eq 0 ];then
    status=2
    echo -e "check_raidstat:$error"|sed -e '/^\s*$/d'|$PERL -ne '{chomp $_;print "$_;"}'
else
    status=0
	echo $status
fi
exit $status
