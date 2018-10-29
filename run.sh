#!/bin/bash

# Skip prompts so we can run unattended
export DEBIAN_FRONTEND=noninteractive

if [ $# -eq 0 ]; then
  echo 'Missing argument, provider name'
  exit 1
fi;

PROVIDER=$1

swapoff -a

apt-get update
apt-get upgrade -y
apt-get install sysbench nginx mysql-server python -y

# Grabs the major version of sysbench so we can use the correct parameters for MySQL
SYSBENCH_MAJOR_VERSION=$(sysbench --version | cut -d ' ' -f 2 | cut -d '.' -f 1)

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

if [ "$SYSBENCH_MAJOR_VERSION" == "0" ]; then
  # Ubuntu 16.04
  mysql -uroot -e "CREATE DATABASE sbtest;"
  sysbench --test=oltp --oltp-table-size=1000000 --mysql-user=root prepare
  sysbench --test=oltp --oltp-table-size=1000000 --mysql-user=root run > results/mysql.log
  sysbench --test=oltp --oltp-table-size=1000000 --mysql-user=root cleanup
else
  # Ubuntu 18.04
  mysql -uroot -e "CREATE DATABASE sbtest;"
  sysbench --db-driver=mysql --table-size=1000000 --mysql-user=root /usr/share/sysbench/oltp_read_write.lua prepare
  sysbench --db-driver=mysql --table-size=1000000 --mysql-user=root /usr/share/sysbench/oltp_read_write.lua run > results/mysql.log
  sysbench --db-driver=mysql --table-size=1000000 --mysql-user=root /usr/share/sysbench/oltp_read_write.lua cleanup
fi

./speedtest-cli --server=16089 > results/speedtest1.log
./speedtest-cli --server=16089 > results/speedtest2.log
./speedtest-cli --server=16089 > results/speedtest3.log

# Wraps it all up in a nice package
tar -zcvf "results-$PROVIDER.tgz" results
