#!/bin/bash
# Sequential read / write test

filename=$1
count=1024
nt=10

echo "Testing with ${filename} OK?"
read
touch "${filename}" || exit

echo "************ Host configuration ***********"
free -h
echo
uname -a
echo

for t in Read Write
do
    echo "************ $t test ************"
    for bs in 8192 32768 65536 500K 1000K
    do
        res=""
        if [ $t = "Read" ]
        then
            for (( i=1; i<=$nt; i++ ))
            do
                sync; 
                echo 3 > /proc/sys/vm/drop_caches
                sync;
                b=`dd if="${filename}" of=/dev/null bs=$bs count=$count |& tail -1| awk -F ', ' '{print $NF}'`
                res="$res, $b"
            done
            echo -e "$count times $bs Bytes\t\t\t\t\t $res"
        else
            for (( i=1; i<=$nt; i++ ))
            do
                sync;
                b=`dd if=/dev/zero of="${filename}" bs=$bs count=$count |& tail -1| awk -F ', ' '{print $NF}'`
                res="$res, $b"
            done
            echo -e "$count times $bs Bytes\t\t\t\t\t $res"
        fi
    done
done
