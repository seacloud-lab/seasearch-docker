#!/bin/bash

function set_env(){
  export SS_CLUSTER_MANAGER_HOST=0.0.0.0
  export SS_CLUSTER_MANAGER_PORT=4081
  export SS_CLUSTER_MANAGER_URL=http://127.0.0.1:4081/
  export SS_CLUSTER_PROXY_HOST=0.0.0.0
  export SS_CLUSTER_PROXY_PORT=4082
}

function set_proxy_env(){
  export SS_CLUSTER_PROXY_HOST=0.0.0.0
  export SS_CLUSTER_PROXY_PORT=4082
}

function set_manager_env(){
  export SS_CLUSTER_MANAGER_HOST=0.0.0.0
  export SS_CLUSTER_MANAGER_PORT=4081
}

cd /opt/cluster

case "${SS_GATEWAY_NODE_TYPE}" in
  "proxy")
    echo "Starting in PROXY mode"
    set_proxy_env
    chmod +x seasearch-proxy
    ./seasearch-proxy
    ;;
    
  "manager")
    echo "Starting in MANAGER mode"
    set_manager_env
    chmod +x cluster-manager
    chmod +x /opt/scripts/register-cluster.sh
    ./cluster-manager &
    . /opt/scripts/register-cluster.sh ${SS_SERVER_CLUSTER_ENPOINTS}
    ;;
    
  *)
    echo "Starting in NORMAL mode"
    set_env
    chmod +x cluster-manager
    chmod +x /opt/scripts/register-cluster.sh
    chmod +x seasearch-proxy
    ./cluster-manager &
    . /opt/scripts/register-cluster.sh ${SS_SERVER_CLUSTER_ENPOINTS} && ./seasearch-proxy &
    ;;
esac

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
