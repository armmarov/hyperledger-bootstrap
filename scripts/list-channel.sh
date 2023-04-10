#!/bin/bash

export FABRIC_CFG_PATH=./config
export CHANNEL_NAME=crosschain



if [ $1 = "orderer1" ]; then
  export OSN_TLS_CA_ROOT_CERT=./ca-repo/fabric-ca-client/orderer/tlsca/tlsca.orderer.com-cert.pem
  export ADMIN_TLS_SIGN_CERT=./ca-repo/orderers/orderer1/tls/server.crt
  export ADMIN_TLS_PRIVATE_KEY=./ca-repo/orderers/orderer1/tls/server.key
  ./bin/osnadmin channel list -o localhost:15050 --ca-file ${OSN_TLS_CA_ROOT_CERT} --client-cert ${ADMIN_TLS_SIGN_CERT} --client-key ${ADMIN_TLS_PRIVATE_KEY}
elif [ $1 = "orderer2" ]; then
  export OSN_TLS_CA_ROOT_CERT=./ca-repo/fabric-ca-client/orderer/tlsca/tlsca.orderer.com-cert.pem
  export ADMIN_TLS_SIGN_CERT=./ca-repo/orderers/orderer2/tls/server.crt
  export ADMIN_TLS_PRIVATE_KEY=./ca-repo/orderers/orderer2/tls/server.key
  ./bin/osnadmin channel list -o localhost:15051 --ca-file ${OSN_TLS_CA_ROOT_CERT} --client-cert ${ADMIN_TLS_SIGN_CERT} --client-key ${ADMIN_TLS_PRIVATE_KEY}
elif [ $1 = "orderer3" ]; then
  export OSN_TLS_CA_ROOT_CERT=./ca-repo/fabric-ca-client/orderer/tlsca/tlsca.orderer.com-cert.pem
  export ADMIN_TLS_SIGN_CERT=./ca-repo/orderers/orderer3/tls/server.crt
  export ADMIN_TLS_PRIVATE_KEY=./ca-repo/orderers/orderer3/tls/server.key
  ./bin/osnadmin channel list -o localhost:15052 --ca-file ${OSN_TLS_CA_ROOT_CERT} --client-cert ${ADMIN_TLS_SIGN_CERT} --client-key ${ADMIN_TLS_PRIVATE_KEY}
elif [ $1 = "peer1" ]; then
  export CORE_PEER_TLS_ENABLED=true
  export CORE_PEER_LOCALMSPID=DummyMSP
  export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/ca-repo/fabric-ca-client/orderer/tlsca/tlsca.orderer.com-cert.pem
  export CORE_PEER_MSPCONFIGPATH=${PWD}/ca-repo/peers/peer1/msp
  export CORE_PEER_ADDRESS=peer1.dummy.com:6051
  ./bin/peer channel list
fi
