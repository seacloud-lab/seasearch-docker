#!/bin/bash

# Check if cluster-manager is running (manager or normal mode only)
echo "Checking if cluster-manager is available..."
SERVICE_URL="http://localhost:4081"
MAX_RETRIES=30
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${SERVICE_URL}/" 2>/dev/null)
    if [ "$HTTP_CODE" != "000" ] && [ "$HTTP_CODE" -lt 500 ]; then
        echo "cluster-manager is available (HTTP $HTTP_CODE)"
        break
    fi

    RETRY_COUNT=$((RETRY_COUNT + 1))

    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo "Error: cluster-manager is not running on localhost:4081"
        echo "This command can only be used in manager or normal mode."
        exit 1
    fi

    echo "Waiting for cluster-manager to start... ($RETRY_COUNT/$MAX_RETRIES)"
    sleep 1
done

# Parameters check
if [ $# -eq 0 ]; then
    echo "Error: incorrect parameters"
    echo "Example:"
    echo "$0 1:192.168.0.1:1000,2:192.168.0.2:1000,..."
    exit 1
fi

echo "Checking if service is available..."
MAX_RETRIES=30
RETRY_COUNT=0

# Get nodes info from parameters
nodes=()
IFS=',' read -ra args <<< "$1"

for arg in "${args[@]}"; do
    arg=$(echo "$arg" | tr -d ' ')
    if [[ $arg =~ ^([0-9]+):([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+):([0-9]+)$ ]]; then
        node_id="${BASH_REMATCH[1]}"
        address="${BASH_REMATCH[2]}:${BASH_REMATCH[3]}"
        nodes+=("{\"node_id\": $node_id, \"address\": \"$address\"}")
    else
        echo "Skip: $arg"
    fi
done

if [ ${#nodes[@]} -eq 0 ]; then
    echo "Error: No valid nodes to register"
    exit 1
fi

json_data=$(IFS=,; echo "[${nodes[*]}]")
echo "Register nodes: $json_data"

# tring to register check
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
                -X PUT "${SERVICE_URL}/api/cluster-nodes" \
                -H "Content-Type: application/json" \
                --data-raw "$json_data" \
                2>/dev/null)
    
    if [ "$HTTP_CODE" != "000" ] && [ "$HTTP_CODE" -lt 400 ]; then
        echo "Cluster register successfully (HTTP $HTTP_CODE)"
        
        # Restart seasearch-proxy for normal mode
        if [ "${SS_GATEWAY_NODE_TYPE}" != "proxy" ] && [ "${SS_GATEWAY_NODE_TYPE}" != "manager" ]; then
            echo "Restarting seasearch-proxy to apply new cluster config..."
            pkill -f "seasearch-proxy" || true
            sleep 1
            cd /opt/cluster && ./seasearch-proxy &
            echo "seasearch-proxy restarted successfully."
        fi
        
        exit 0
    fi
    
    RETRY_COUNT=$((RETRY_COUNT + 1))
    
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo "✗ Error: Registration failed after $MAX_RETRIES attempts (last HTTP code: ${HTTP_CODE:-timeout})"
        exit 1
    fi
    
    echo "Cluster register failed (HTTP ${HTTP_CODE:-timeout}), retrying in 1s... ($RETRY_COUNT/$MAX_RETRIES)"
    sleep 1
done
