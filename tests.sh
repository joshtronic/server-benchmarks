#!/bin/bash

if [ $# -eq 0 ]; then
    echo 'Missing argument, provider name'
    exit 1
fi;

PROVIDER=$1

swapoff -a

apt-get update
apt-get upgrade -y
apt-get install sysbench apache2 mailutils mysql-server python -y

wget -O speedtest-cli https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py
chmod +x speedtest-cli

mkdir results

cat /proc/cpuinfo > results/cpuinfo.log

sysbench --test=cpu run > results/cpu.log

sysbench --test=memory run > results/memory-read.log
sysbench --test=memory --memory-oper=write run > results/memory-write.log

sysbench --test=fileio prepare
sysbench --test=fileio --file-test-mode=rndrw run > results/fileio.log
sysbench --test=fileio cleanup

mysql -uroot -e "CREATE DATABASE sbtest;"
sysbench --test=oltp --oltp-table-size=1000000 --mysql-user=root prepare
sysbench --test=oltp --oltp-table-size=1000000 --mysql-user=root run > results/mysql.log
sysbench --test=oltp --oltp-table-size=1000000 --mysql-user=root cleanup

./speedtest-cli --server=7340 > results/speedtest1.log
./speedtest-cli --server=7340 > results/speedtest2.log
./speedtest-cli --server=7340 > results/speedtest3.log

ab -kc 1000 -n 10000 http://127.0.0.1/ > results/ab.log

tar -zcvf "results-$PROVIDER.tgz" results
