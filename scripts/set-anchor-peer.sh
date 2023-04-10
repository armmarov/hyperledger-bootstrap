#!/bin/bash

export FABRIC_CFG_PATH=./config
export CHANNEL_NAME=crosschain

export ORDERER_CA=${PWD}/ca-repo/fabric-ca-client/orderer/tlsca/tlsca.orderer.com-cert.pem
export ORDERER_HOST=orderer1.dummy.com
export ORDERER_PORT=14050
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

rm -rf temp/* && touch temp/.gitkeep
./bin/peer channel fetch config temp/config_block.pb -o ${ORDERER_HOST}:${ORDERER_PORT} --ordererTLSHostnameOverride ${ORDERER_HOST} -c ${CHANNEL_NAME} --tls --cafile ${ORDERER_CA}
./bin/configtxlator proto_decode --input temp/config_block.pb --type common.Block --output temp/config_block.json
jq .data.data[0].payload.data.config temp/config_block.json > temp/${CORE_PEER_LOCALMSPID}config.json
jq '.channel_group.groups.Application.groups.DummyMSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "'${CORE_PEER_HOST}'","port": '${CORE_PEER_PORT}'}]},"version": "'${VERSION}'"}}' temp/${CORE_PEER_LOCALMSPID}config.json > temp/${CORE_PEER_LOCALMSPID}modified_config.json
./bin/configtxlator proto_encode --input temp/${CORE_PEER_LOCALMSPID}config.json --type common.Config --output temp/original_config.pb
./bin/configtxlator proto_encode --input temp/${CORE_PEER_LOCALMSPID}modified_config.json --type common.Config --output temp/modified_config.pb
./bin/configtxlator compute_update --channel_id "${CHANNEL_NAME}" --original temp/original_config.pb --updated temp/modified_config.pb --output temp/config_update.pb
./bin/configtxlator proto_decode --input temp/config_update.pb --type common.ConfigUpdate --output temp/config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"'${CHANNEL_NAME}'", "type":2}},"data":{"config_update":'$(cat temp/config_update.json)'}}}' | jq . > temp/config_update_in_envelope.json
./bin/configtxlator proto_encode --input temp/config_update_in_envelope.json --type common.Envelope --output temp/${CORE_PEER_LOCALMSPID}anchors.tx
./bin/peer channel update -o ${ORDERER_HOST}:${ORDERER_PORT} --ordererTLSHostnameOverride ${ORDERER_HOST} -c ${CHANNEL_NAME} -f temp/${CORE_PEER_LOCALMSPID}anchors.tx --tls --cafile ${ORDERER_CA}
