#!/bin/bash

export LANGUAGE=en_US;

ETH=eth0
DISK=sda

if [[ "$1" == "stop" ]]; then
    #killall -9 iostat;
    killall -9 vmstat;
    killall -9 top
    killall -9 report_top.sh;
    exit;
fi

function diskIO()
{
    echo "time rkB wkB util" >diskio.report;
    while true
    do
        iostat -k -x $DISK 1 10| awk '/sda/{print strftime("%T", systime()),$6,$7,$12}' >>diskio.report;
        #sleep 2;
    done
}

function cpumem()
{
    echo "time us sy id si" > cpu.report
    echo "time swpd free buff cache" > mem.report;
    while true
    do
        top -b -d1 -n10 |awk '/Cpu/ {print strftime("%T", systime()), $2, $3, $5, $8}' >> cpu.report;
        vmstat 1 10 | awk '{if($0~/^[ 0-9\t]+$/){print strftime("%T", systime()), $3,$4,$5,$6}}' >> mem.report;
        sleep 1;
    done
}

function netIO()
{
    echo "time RX TX" > net.report;
    rxtx=(`ifconfig $ETH | grep 'RX bytes' | awk -F"[ :]+" '{print $4, $9}'`);
    while true; do    
	tmprxtx=(`ifconfig $ETH | grep 'RX bytes' | awk -F"[ :]+" '{print $4, $9}'`);
	rx=$(( ${tmprxtx[0]} - ${rxtx[0]} ));
	tx=$(( ${tmprxtx[1]} - ${rxtx[1]} ));
	rxtx=(${tmprxtx[*]});
	echo `date +"%H:%M:%S"` " $rx $tx" >>net.report;
	
	sleep 1;
    done
}

diskIO &
cpumem &
netIO &

exit
