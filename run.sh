#!/bin/bash

# Skip prompts so we can run unattended
export DEBIAN_FRONTEND=noninteractive

if [ $# -eq 0 ]; then
  echo 'Missing argument, provider name'
  exit 1
fi;

PROVIDER=$1
SPEEDTEST_SERVER=1774

swapoff -a

apt-get update

apt-get upgrade -q -y -u  -o Dpkg::Options::="--force-confdef" \
  --allow-downgrades --allow-remove-essential --allow-change-held-packages \
  --allow-change-held-packages --allow-unauthenticated

apt-get install sysbench nginx mysql-server python redis-server -y

wget -O speedtest-cli https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py
chmod +x speedtest-cli

mkdir results

cat /proc/cpuinfo > results/proc-cpuinfo.txt
uname -a > results/uname-a.txt
mysql --version > results/mysql-version.txt
redis-server --version > results/redis-server-version.txt

sysbench cpu run > results/sysbench-cpu.txt

sysbench memory run > results/sysbench-memory-read.txt
sysbench --memory-oper=write memory run > results/sysbench-memory-write.txt

sysbench fileio prepare
sysbench --file-test-mode=rndrw fileio run > results/sysbench-fileio.txt
sysbench fileio cleanup

sysbench --threads=10 threads run > results/sysbench-threads.txt
sysbench --threads=10 mutex run > results/sysbench-mutex.txt

mysql -uroot -e "CREATE DATABASE sbtest;"

TESTS=(
  "bulk_insert"
  "oltp_delete"
  "oltp_insert"
  "oltp_point_select"
  "oltp_read_only"
  "oltp_read_write"
  "oltp_update_index"
  "oltp_update_non_index"
  "oltp_write_only"
  "select_random_points"
  "select_random_ranges"
)

for TEST in "${TESTS[@]}"; do
  sysbench --db-driver=mysql --table-size=1000000 --mysql-user=root "/usr/share/sysbench/$TEST.lua" prepare
  sysbench --db-driver=mysql --table-size=1000000 --mysql-user=root "/usr/share/sysbench/$TEST.lua" run > "results/sysbench-mysql-$TEST.txt"
  sysbench --db-driver=mysql --table-size=1000000 --mysql-user=root "/usr/share/sysbench/$TEST.lua" cleanup
done

redis-benchmark -q -n 100000 --csv > results/redis-benchmark.txt

./speedtest-cli --json --secure --single --server="$SPEEDTEST_SERVER" > results/speedtest1.json
./speedtest-cli --json --secure --single --server="$SPEEDTEST_SERVER" > results/speedtest2.json
./speedtest-cli --json --secure --single --server="$SPEEDTEST_SERVER" > results/speedtest3.json

# Wraps it all up in a nice package
tar -zcvf "results-$PROVIDER.tgz" results
