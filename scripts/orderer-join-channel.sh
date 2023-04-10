#!/bin/bash

export FABRIC_CFG_PATH=./config
export CHANNEL_NAME=crosschain

export OSN_TLS_CA_ROOT_CERT=./ca-repo/fabric-ca-client/orderer/tlsca/tlsca.orderer.com-cert.pem

if [ $1 = "orderer1" ]; then
  export ADMIN_TLS_SIGN_CERT=./ca-repo/orderers/orderer1/tls/server.crt
  export ADMIN_TLS_PRIVATE_KEY=./ca-repo/orderers/orderer1/tls/server.key
  ./bin/osnadmin channel join --channelID ${CHANNEL_NAME} --config-block ./artifacts/${CHANNEL_NAME}.block -o localhost:15050 --ca-file ${OSN_TLS_CA_ROOT_CERT} --client-cert ${ADMIN_TLS_SIGN_CERT} --client-key ${ADMIN_TLS_PRIVATE_KEY}
elif [ $1 = "orderer2" ]; then
  export ADMIN_TLS_SIGN_CERT=./ca-repo/orderers/orderer2/tls/server.crt
  export ADMIN_TLS_PRIVATE_KEY=./ca-repo/orderers/orderer2/tls/server.key
  ./bin/osnadmin channel join --channelID ${CHANNEL_NAME} --config-block ./artifacts/${CHANNEL_NAME}.block -o localhost:15051 --ca-file ${OSN_TLS_CA_ROOT_CERT} --client-cert ${ADMIN_TLS_SIGN_CERT} --client-key ${ADMIN_TLS_PRIVATE_KEY}
elif [ $1 = "orderer3" ]; then
  export ADMIN_TLS_SIGN_CERT=./ca-repo/orderers/orderer3/tls/server.crt
  export ADMIN_TLS_PRIVATE_KEY=./ca-repo/orderers/orderer3/tls/server.key
  ./bin/osnadmin channel join --channelID ${CHANNEL_NAME} --config-block ./artifacts/${CHANNEL_NAME}.block -o localhost:15052 --ca-file ${OSN_TLS_CA_ROOT_CERT} --client-cert ${ADMIN_TLS_SIGN_CERT} --client-key ${ADMIN_TLS_PRIVATE_KEY}
fi
