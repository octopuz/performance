#!/bin/bash

export LANGUAGE=en_US;

ETH=eth2
DISK=sdb

if [[ "$1" == "stop" ]]; then
    killall -9 iostat;
    killall -9 vmstat;
    killall -9 report.sh;
    exit;
fi

function diskIO()
{
    echo "time rkB wkB util" >diskio.report;
    while true
    do
        iostat -k -x 1 $DISK 10| awk '/sdb/{print strftime("%T", systime()),$6,$7,$12}' >>diskio.report;
    done
}

function cpumem()
{
    echo "time swpd free buff cache us sy id wa st" > cpumem.report;
    while true
    do
        vmstat 1 10| awk '{if($0~/^[ 0-9\t]+$/ && $13>2){print strftime("%T", systime()), $3,$4,$5,$6,$13,$14,$15,$16,$17}}' >> cpumem.report;
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
