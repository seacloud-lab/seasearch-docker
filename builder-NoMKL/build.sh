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
    
    tar -czvf seasearch-$version.tar.gz /opt/faiss/build /opt/seasearch/seasearch  
      
    echo "seasearch-$version.tar.gz 打包完成."  
}  
  
# check args  
if [ "$#" -ne 1 ]; then  
    echo "Usage: $0 <version>"  
    exit 1  
fi  
  
# call 
main "$1"