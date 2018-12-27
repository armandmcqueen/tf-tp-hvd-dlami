#!/bin/bash

for i in $(seq 1 $DEEPLEARNING_WORKERS_COUNT)
do
ssh -oStrictHostKeyChecking=no deeplearning-worker$i uptime
ssh ubuntu@deeplearning-worker$i 'sudo mkdir /fsx'
ssh ubuntu@deeplearning-worker$i 'sudo mount -t lustre <filesystemid>.fsx.<region>.amazonaws.com@tcp:/fsx /fsx'
done
