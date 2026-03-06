#!/bin/bash

#start server
cd /opt
chmod +x /opt/cluster/cluster-manager
./cluster-manager &
chmod +x /opt/cluster/seasearch-proxy
./seasearch-proxy &

echo "This is a idle script (infinite loop) to keep container running."

function cleanup(){
  kill -s SIGTERM $!
  exit 0
}

trap cleanup SIGINT SIGTERM

while [ 1 ]
do
  sleep 60 & wait $!
done
