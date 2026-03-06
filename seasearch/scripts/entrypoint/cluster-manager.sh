#!/bin/bash

function set_env(){
  export SS_CLUSTER_MANAGER_HOST=127.0.0.1
  export SS_CLUSTER_MANAGER_PORT=4081
  export SS_CLUSTER_MANAGER_URL=http://127.0.0.1:4081/
  export SS_CLUSTER_PROXY_HOST=0.0.0.0
  export SS_CLUSTER_PROXY_PORT=4082
}

#start server
set_env
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
