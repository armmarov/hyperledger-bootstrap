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

if [ $2 = "fetch" ]; then
  # Owner of the channel will fetch the current channel block
  rm -rf temp/* && touch temp/.gitkeep
  ./bin/peer channel fetch config temp/config_block.pb -o ${ORDERER_HOST}:${ORDERER_PORT} --ordererTLSHostnameOverride ${ORDERER_HOST} -c ${CHANNEL_NAME} --tls --cafile ${ORDERER_CA}

elif [ $2 = "modify" ]; then
  # Then they share to the new organization to add their info by themselves. CORE_PEER_LOCALMSPID must defined by the new organization
  ./bin/configtxgen -printOrg ${CORE_PEER_LOCALMSPID} > temp/${CORE_PEER_LOCALMSPID}.json
  ./bin/configtxlator proto_decode --input temp/config_block.pb --type common.Block --output temp/config_block.json
  jq .data.data[0].payload.data.config temp/config_block.json > temp/config.json
  jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"'${CORE_PEER_LOCALMSPID}'":.[1]}}}}}' temp/config.json temp/${CORE_PEER_LOCALMSPID}.json > temp/modified_config.json
  ./bin/configtxlator proto_encode --input temp/config.json --type common.Config --output temp/original_config.pb
  ./bin/configtxlator proto_encode --input temp/modified_config.json --type common.Config --output temp/modified_config.pb
  ./bin/configtxlator compute_update --channel_id "${CHANNEL_NAME}" --original temp/original_config.pb --updated temp/modified_config.pb --output temp/config_update.pb
  ./bin/configtxlator proto_decode --input temp/config_update.pb --type common.ConfigUpdate --output temp/config_update.json
  echo '{"payload":{"header":{"channel_header":{"channel_id":"'${CHANNEL_NAME}'", "type":2}},"data":{"config_update":'$(cat temp/config_update.json)'}}}' | jq . > temp/config_update_in_envelope.json
  ./bin/configtxlator proto_encode --input temp/config_update_in_envelope.json --type common.Envelope --output temp/join_application_envelope.pb

elif [ $2 = "sign" ]; then
  # All organization will sign the application envelope
  ./bin/peer channel signconfigtx -f temp/join_application_envelope.pb

elif [ $2 = "update" ]; then
  # Last sign organization will update to the block
  ./bin/peer channel update -o ${ORDERER_HOST}:${ORDERER_PORT} --ordererTLSHostnameOverride ${ORDERER_HOST} -c ${CHANNEL_NAME} -f temp/join_application_envelope.pb --tls --cafile ${ORDERER_CA}
fi