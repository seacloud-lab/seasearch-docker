#!/bin/bash

# set env for complicates
function set_env(){
  export ZINC_FIRST_ADMIN_USER=$SS_FIRST_ADMIN_USER
  export ZINC_FIRST_ADMIN_PASSWORD=$SS_FIRST_ADMIN_PASSWORD
  export ZINC_ETCD_USERNAME=$SS_ETCD_USERNAME
  export ZINC_ETCD_PASSWORD=$SS_ETCD_PASSWORD
  export ZINC_ETCD_ENDPOINTS=$SS_ETCD_ENDPOINTS
  export ZINC_ETCD_PREFIX=$SS_ETCD_PREFIX
}

#start server
cd /opt/seasearch
chmod +x /opt/seasearch/seasearch
set_env
./seasearch

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