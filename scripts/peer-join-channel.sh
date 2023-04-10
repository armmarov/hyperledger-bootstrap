#!/bin/bash

export FABRIC_CFG_PATH=./config
export CHANNEL_NAME=crosschain

export CORE_PEER_LOCALMSPID=DummyMSP
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/ca-repo/fabric-ca-client/orderer/tlsca/tlsca.orderer.com-cert.pem
export CORE_PEER_MSPCONFIGPATH=${PWD}/ca-repo/admin/msp

if [ $1 = "peer1" ]; then    
  export CORE_PEER_ADDRESS=peer1.dummy.com:6051
  ./bin/peer channel join -b ./artifacts/${CHANNEL_NAME}.block
elif [ $1 = "peer2" ]; then
  export CORE_PEER_ADDRESS=peer2.dummy.com:5051
  ./bin/peer channel join -b ./artifacts/${CHANNEL_NAME}.block
elif [ $1 = "peer3" ]; then
  export CORE_PEER_ADDRESS=peer3.dummy.com:4051
  ./bin/peer channel join -b ./artifacts/${CHANNEL_NAME}.block
fi
