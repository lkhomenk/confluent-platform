#!/bin/bash

rp_cfg_file="/etc/kafka-rest/kafka-rest.properties"

: ${RP_ID:=1}
: ${RP_PORT:=8082}
: ${RP_SCHEMA_REGISTRY_URL:=$SR_PORT_8081_TCP_ADDR:$SR_PORT_8081_TCP_PORT}
: ${RP_ZOOKEEPER_CONNECT:=$ZOOKEEPER_PORT_2181_TCP_ADDR:$ZOOKEEPER_PORT_2181_TCP_PORT}
: ${RP_DEBUG:=false}

export RP_ID
export RP_PORT
export RP_SCHEMA_REGISTRY_URL
export RP_ZOOKEEPER_CONNECT
export RP_DEBUG

# Download the config file, if given a URL
if [ ! -z "$RP_CFG_URL" ]; then
  echo "[RP] Downloading RP config file from ${RP_CFG_URL}"
  curl --location --silent --insecure --output ${rp_cfg_file} ${RP_CFG_URL}
  if [ $? -ne 0 ]; then
    echo "[RP] Failed to download ${RP_CFG_URL} exiting."
    exit 1
  fi
fi

echo '# Generated by rest-proxy-docker.sh' > ${rp_cfg_file}
for var in $(env | grep -v '^RP_CFG_' | grep '^RP_' | sort); do
  key=$(echo $var | sed -r 's/RP_(.*)=.*/\1/g' | tr A-Z a-z | tr _ .)
  value=$(echo $var | sed -r 's/.*=(.*)/\1/g')
  echo "${key}=${value}" >> ${rp_cfg_file}
done

exec /usr/bin/kafka-rest-start ${rp_cfg_file}
