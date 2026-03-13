#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Error: incorrect parameters"
    echo "Example:"
    echo "$0 1:192.168.0.1:1000,2:192.168.0.2:1000,..."
    exit 1
fi

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

json_data=$(printf "%s," "${nodes[@]}")
json_data="[${json_data%,}]"

echo "Register nodes: $json_data"
curl -X PUT http://localhost:4081/api/cluster-nodes \
    -H "Content-Type: application/json" \
    --data-raw "$json_data"

echo ""
