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
    exec ./seasearch-proxy
    ;;

  *)
    if [ "${SS_GATEWAY_NODE_TYPE}" == "manager" ]; then
        echo "Starting in MANAGER mode"
        set_manager_env
    else
        echo "Starting in NORMAL mode"
        set_env
        chmod +x seasearch-proxy
    fi

    chmod +x cluster-manager
    ./cluster-manager &
    manager_pid=$!

    cleanup() {
        [ -z "${manager_pid}" ] || kill -s SIGTERM "${manager_pid}" 2>/dev/null || true
        [ -z "${proxy_pid}" ] || kill -s SIGTERM "${proxy_pid}" 2>/dev/null || true
        [ -z "${manager_pid}" ] || wait "${manager_pid}" 2>/dev/null || true
        [ -z "${proxy_pid}" ] || wait "${proxy_pid}" 2>/dev/null || true
    }

    trap 'cleanup; exit 0' SIGINT SIGTERM

    if [ -n "${SS_SERVER_CLUSTER_ENPOINTS}" ]; then
        SS_SKIP_PROXY_RESTART=true /opt/scripts/register-cluster.sh "${SS_SERVER_CLUSTER_ENPOINTS}" || {
            exit_code=$?
            cleanup
            exit "${exit_code}"
        }
    fi

    if [ "${SS_GATEWAY_NODE_TYPE}" == "manager" ]; then
        wait "${manager_pid}"
        exit $?
    fi

    ./seasearch-proxy &
    proxy_pid=$!

    wait -n "${manager_pid}" "${proxy_pid}"
    exit_code=$?
    cleanup
    exit "${exit_code}"
    ;;
esac
