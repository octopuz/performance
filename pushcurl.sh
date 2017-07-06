#!/bin/sh

num=$1

if [ ! $num ] || [ $num -le 0 ];then
    echo "input a parameter being an integer && greater than 0."
    exit 1
fi

if [ ! -f ./test.log ];then
    touch test.log
fi

:>./test.log
date +%X >> test.log

for((i=1;i<=$num;i++))
do
    `curl -vo /dev/null -s -w %{http_code}:%{content_type}:%{time_namelookup}:%{time_connect}:%{time_total}:%{speed_download} http://fcd.hyfljhzy.bid/img/$i.jpg -x 117.169.16.179:80 >> test.log`
    echo '' >> test.log
done

date +%X >> test.log
