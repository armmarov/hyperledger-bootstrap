#!/bin/bash

export FABRIC_CFG_PATH=./config
export CHANNEL_NAME=crosschain

export CC_NAME=token_contract
export CC_VERSION=1.0.0
export CC_SEQUENCE=1

export ORDERER_CA=${PWD}/ca-repo/fabric-ca-client/orderer/tlsca/tlsca.orderer.com-cert.pem
export ORDERER_HOST=orderer1.dummy.com
export ORDERER_PORT=14050

export CORE_PEER_LOCALMSPID=DummyMSP
export CORE_PEER_TLS_ENABLED=true
#export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/ca-repo/fabric-ca-client/orderer/tlsca/tlsca.orderer.com-cert.pem
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/ca-repo/peers/peer1/tls/ca.crt
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

if [ $2 = "list-installed" ]; then
  ./bin/peer chaincode list -o ${ORDERER_HOST}:${ORDERER_PORT} --ordererTLSHostnameOverride ${ORDERER_HOST} --tls --cafile ${ORDERER_CA} --peerAddresses ${CORE_PEER_ADDRESS} --tlsRootCertFiles ${CORE_PEER_TLS_ROOTCERT_FILE} --channelID ${CHANNEL_NAME} --installed
fi

if [ $2 = "list-instantiated" ]; then
  ./bin/peer chaincode list -o ${ORDERER_HOST}:${ORDERER_PORT} --ordererTLSHostnameOverride ${ORDERER_HOST} --tls --cafile ${ORDERER_CA} --peerAddresses ${CORE_PEER_ADDRESS} --tlsRootCertFiles ${CORE_PEER_TLS_ROOTCERT_FILE} --channelID ${CHANNEL_NAME} --instantiated
fi

if [ $2 = "list" ]; then
  ./bin/peer chaincode list --channelID ${CHANNEL_NAME}
fi

if [ $2 = "package" ]; then
  ./bin/peer lifecycle chaincode package ./chaincode/out/${CC_NAME}.tar.gz --path ${PWD}/chaincode/token-erc-20 --lang golang --label ${CC_NAME}_${CC_VERSION}
fi

if [ $2 = "install" ]; then
  ./bin/peer lifecycle chaincode install ./chaincode/out/${CC_NAME}.tar.gz
fi

if [ $2 = "approve" ]; then
  CALC_PACKAGE_ID=$(./bin/peer lifecycle chaincode calculatepackageid ./chaincode/out/${CC_NAME}.tar.gz)
  PACKAGE_ID=`./bin/peer lifecycle chaincode queryinstalled --output json | jq -r 'try (.installed_chaincodes[].package_id)' | grep ^${CALC_PACKAGE_ID}$`
  ./bin/peer lifecycle chaincode approveformyorg -o ${ORDERER_HOST}:${ORDERER_PORT} --ordererTLSHostnameOverride ${ORDERER_HOST} --tls --cafile ${ORDERER_CA} --channelID ${CHANNEL_NAME} --name ${CC_NAME} --version ${CC_VERSION} --package-id ${PACKAGE_ID} --sequence ${CC_SEQUENCE} --init-required
fi

if [ $2 = "check" ]; then
  ./bin/peer lifecycle chaincode checkcommitreadiness --channelID ${CHANNEL_NAME} --name ${CC_NAME} --version ${CC_VERSION} --sequence ${CC_SEQUENCE} --init-required --output json
fi

if [ $2 = "commit" ]; then
  ./bin/peer lifecycle chaincode commit -o ${ORDERER_HOST}:${ORDERER_PORT} --ordererTLSHostnameOverride ${ORDERER_HOST} --tls --cafile ${ORDERER_CA} --channelID ${CHANNEL_NAME} --name ${CC_NAME} --peerAddresses ${CORE_PEER_ADDRESS} --tlsRootCertFiles ${CORE_PEER_TLS_ROOTCERT_FILE} --version ${CC_VERSION} --sequence ${CC_SEQUENCE} --init-required
fi

if [ $2 = "query-committed" ]; then
  ./bin/peer lifecycle chaincode querycommitted --channelID ${CHANNEL_NAME} --name ${CC_NAME}
fi

if [ $2 = "invoke-init" ]; then
  ./bin/peer chaincode invoke -o ${ORDERER_HOST}:${ORDERER_PORT} --ordererTLSHostnameOverride ${ORDERER_HOST} --tls --cafile ${ORDERER_CA} --channelID ${CHANNEL_NAME} --name ${CC_NAME} --peerAddresses ${CORE_PEER_ADDRESS} --tlsRootCertFiles ${CORE_PEER_TLS_ROOTCERT_FILE} --isInit -c '{"function":"Initialize","Args":["Wrapped ZTX", "wZTX", "6"]}'
fi

if [ $2 = "invoke-mint" ]; then
  ./bin/peer chaincode invoke -o ${ORDERER_HOST}:${ORDERER_PORT} --ordererTLSHostnameOverride ${ORDERER_HOST} --tls --cafile ${ORDERER_CA} --channelID ${CHANNEL_NAME} --name ${CC_NAME} --peerAddresses ${CORE_PEER_ADDRESS} --tlsRootCertFiles ${CORE_PEER_TLS_ROOTCERT_FILE} -c '{"function":"Mint","Args":["5000"]}'
fi

if [ $2 = "query-balance" ]; then
  ./bin/peer chaincode query --channelID ${CHANNEL_NAME} --name ${CC_NAME} -c '{"function":"ClientAccountBalance","Args":[]}'
fi