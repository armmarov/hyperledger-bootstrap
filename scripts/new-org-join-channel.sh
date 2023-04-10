#!/bin/bash

export FABRIC_CFG_PATH=./config
export CHANNEL_NAME=crosschain

# Must be pointing to the original orderer
export ORDERER_CA=${PWD}/temp/tlsca.orderer.com-cert.pem
export ORDERER_HOST=orderer1.dummy.com
export ORDERER_PORT=14050

# Pointing to the new org peer
export CORE_PEER_LOCALMSPID=DummyMSP
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/ca-repo/fabric-ca-client/orderer/tlsca/tlsca.orderer.com-cert.pem
export CORE_PEER_MSPCONFIGPATH=${PWD}/ca-repo/admin/msp

if [ $1 = "peer1" ]; then
  export CORE_PEER_HOST=peer1.dummy.com
  export CORE_PEER_PORT=6051  
elif [ $1 = "peer2" ]; then
  export CORE_PEER_HOST=peer2.dummy.com
  export CORE_PEER_PORT=5051
elif [ $1 = "peer3" ]; then
  export CORE_PEER_HOST=peer3.dummy.com
  export CORE_PEER_PORT=4051
else
  echo "Select either peer1, peer2 or peer3"
  exit 0
fi

export CORE_PEER_ADDRESS=${CORE_PEER_HOST}:${CORE_PEER_PORT}
export VERSION=1

if [ $2 = "fetch" ]; then
  ./bin/peer channel fetch 0 temp/${CHANNEL_NAME}.block -o ${ORDERER_HOST}:${ORDERER_PORT} --ordererTLSHostnameOverride ${ORDERER_HOST} -c ${CHANNEL_NAME} --tls --cafile ${ORDERER_CA}

elif [ $2 = "join" ]; then
  ./bin/peer channel join -b ${CHANNEL_NAME}.block
fi