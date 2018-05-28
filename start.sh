#!/bin/bash

ssh-copy-id "root@$2"

rsync -avz run.sh "root@$2:~/"

ssh "root@$2" "./run.sh $1"

rsync -avz "root@$2:~/results-$1.tgz" ./

ab -kc 1000 -n 10000 "http://$2/" > "./ab-$1.log"
