#!/bin/bash
set -euo pipefail

set_env() {
  export SS_CLUSTER_MANAGER_HOST=0.0.0.0
  export SS_CLUSTER_MANAGER_PORT=4081
  export SS_CLUSTER_MANAGER_URL=http://127.0.0.1:4081/
  export SS_CLUSTER_PROXY_HOST=0.0.0.0
  export SS_CLUSTER_PROXY_PORT=4082
}

set_proxy_env() {
  export SS_CLUSTER_PROXY_HOST=0.0.0.0
  export SS_CLUSTER_PROXY_PORT=4082
}

set_manager_env() {
  export SS_CLUSTER_MANAGER_HOST=0.0.0.0
  export SS_CLUSTER_MANAGER_PORT=4081
}

manager_pid=""
proxy_pid=""

cleanup() {
  [ -n "$manager_pid" ] && kill -s SIGTERM "$manager_pid" 2>/dev/null || true
  [ -n "$proxy_pid" ]   && kill -s SIGTERM "$proxy_pid"   2>/dev/null || true
  [ -n "$manager_pid" ] && wait "$manager_pid" 2>/dev/null || true
  [ -n "$proxy_pid" ]   && wait "$proxy_pid"   2>/dev/null || true
}

cd /opt/cluster || exit 1

case "${SS_GATEWAY_NODE_TYPE:-}" in
  "proxy")
    echo "Starting in PROXY mode"
    set_proxy_env
    exec ./seasearch-proxy
    ;;

  "manager"|"")
    if [ "${SS_GATEWAY_NODE_TYPE:-}" = "manager" ]; then
      echo "Starting in MANAGER mode"
      set_manager_env
    else
      echo "Starting in NORMAL mode"
      set_env
    fi

    ./cluster-manager &
    manager_pid=$!

    trap 'cleanup; exit 143' SIGINT SIGTERM

    if [ -n "${SS_SERVER_CLUSTER_ENDPOINTS:-}" ]; then
      if ! SS_SKIP_PROXY_RESTART=true /opt/scripts/register-cluster.sh "${SS_SERVER_CLUSTER_ENDPOINTS}"; then
        rc=$?
        cleanup
        exit "$rc"
      fi
    fi

    if [ "${SS_GATEWAY_NODE_TYPE:-}" = "manager" ]; then
      wait "$manager_pid"
      exit $?
    fi

    ./seasearch-proxy &
    proxy_pid=$!

    wait -n "$manager_pid" "$proxy_pid"
    rc=$?
    cleanup
    exit "$rc"
    ;;

  *)
    echo "Unknown SS_GATEWAY_NODE_TYPE: ${SS_GATEWAY_NODE_TYPE}" >&2
    exit 1
    ;;
esac
