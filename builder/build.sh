#!/bin/bash  
   
main() {  
    local version=$1

    cd /opt/seasearch/web || exit 1

    npm install  
    npm run build

    cd /opt/seasearch || exit 1
    export CGO_ENABLED=1
    go mod tidy
    go build -o seasearch ./cmd/zincsearch/
    go build -o seasearch-proxy ./cmd/zinc-proxy/main.go
    go build -o cluster-manager ./cmd/cluster-manager/main.go

    mv seasearch-proxy /opt/seasearch-proxy
    mv cluster-manager /opt/cluster-manager
    
    tar -czvf seasearch-$version.tar.gz /opt/faiss/build /opt/seasearch/seasearch /opt/seasearch/assets /opt/seasearch-cluster/seasearch-proxy /opt/seasearch-cluster/cluster-manager
      
    echo "seasearch-$version.tar.gz 打包完成."  
}  
  
# check args  
if [ "$#" -ne 1 ]; then  
    echo "Usage: $0 <version>"  
    exit 1  
fi  
  
# call 
main "$1"