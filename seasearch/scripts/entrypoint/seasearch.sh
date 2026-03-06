#!/bin/bash

# set env for complicates
function set_env(){
  export ZINC_FIRST_ADMIN_USER=$SS_FIRST_ADMIN_USER
  export ZINC_FIRST_ADMIN_PASSWORD=$SS_FIRST_ADMIN_PASSWORD

  # for word differents
  export ZINC_PLUGIN_GSE_ENABLE=true
  export ZINC_PLUGIN_GSE_DICT_PATH=/opt/seasearch/assets
  
  # for the configurations map in s3
  export SS_S3_BUCKET=${SS_S3_BUCKET:-${S3_SS_BUCKET:-}}
  export SS_S3_ACCESS_ID=${SS_S3_ACCESS_ID:-${S3_KEY_ID:-}}
  export SS_S3_USE_V4_SIGNATURE=${SS_S3_USE_V4_SIGNATURE:-${S3_USE_V4_SIGNATURE:-true}}
  export SS_S3_ACCESS_SECRET=${SS_S3_ACCESS_SECRET:-${S3_SECRET_KEY:-}}
  export SS_S3_ENDPOINT=${SS_S3_ENDPOINT:-${S3_HOST:-}}
  export SS_S3_USE_HTTPS=${SS_S3_USE_HTTPS:-${S3_USE_HTTPS:-true}}
  export SS_S3_PATH_STYLE_REQUEST=${SS_S3_PATH_STYLE_REQUEST:-${S3_PATH_STYLE_REQUEST:-true}}
  export SS_S3_AWS_REGION=${SS_S3_AWS_REGION:-${S3_AWS_REGION:-us-east-1}}
  export SS_S3_SSE_C_KEY=${SS_S3_SSE_C_KEY:-${S3_SSE_C_KEY:-}}
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
