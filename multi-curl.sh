#!/bin/sh

PROCESS_NO=5            # Maximum process number of concurrence access
job_no=$1               # Total job number of user-input according to the actual test data

if [ ! $job_no ] || [ $job_no -le 0 ];then
    echo "input a parameter being an integer && greater than 0."
    exit 1
fi

if [ ! -f ./pushresult.log ];then
    touch pushresult.log
fi

# Create a function as a process executed inside for loop later.
function runcurl
{
    `curl -vo /dev/null -s -w %{http_code}:%{content_type}:%{time_namelookup}:%{time_connect}:%{time_total}:%{speed_download} http://vrmind.cn/test{$i}.png >> pushresult.log`
    echo '' >> pushresult.log
}

# Create a pipe used for storing multi-process marks
tmpfile="/tmp/$$.fifo"
mkfifo $tmpfile
exec 777<>$tmpfile      # Make fd777 pointed to fifo type
rm -f $tmpfile

# Save processes number of "Enter" into fd777
for((i=1;i<=$PROCESS_NO;i++))
do
    echo "init sub job $i."
done >&777

# Start jobs
:>./pushresult.log                  # Clear the result file.
date +%X >> pushresult.log          # Record the start time when running.

for((i=1;i<=$job_no;i++))
do
    read line
    echo "$line"
    {
        runcurl
        echo >&777
    }&
done <&777

wait
date +%X >> pushresult.log
exec 777>&-
exit 0
