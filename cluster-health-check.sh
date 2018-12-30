#!/bin/bash

for i in $(seq 1 $DEEPLEARNING_WORKERS_COUNT)
do
echo "Health check on worker: deeplearning-worker$i"
ssh -oStrictHostKeyChecking=no deeplearning-worker$i uptime
done
