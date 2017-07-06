#!/bin/bash

export LANGUAGE=en_US;

ETH=eth0
DISK=sda

if [[ "$1" == "stop" ]]; then
    #killall -9 iostat;
    killall -9 vmstat;
    killall -9 mpstat;
    killall -9 report_mpstat.sh;
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

function cpu()
{
    #num=`lscpu |awk '/^CPU\(s\)/{print $2}'`
    echo "time cpu us sy si id" > cpu.report
    while true
    do
        mpstat -P ALL 1 10 |awk '$3!="all" && $4>1.0 {print $1, $3, $4, $6, $9, $12}' >> cpu.report
        sleep 1;
    done
}

function mem()
{
    echo "time swpd free buff cache" > mem.report;
    while true
    do
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
cpu &
mem &
netIO &

exit
