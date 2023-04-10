#!/bin/bash

export FABRIC_CFG_PATH=./config
export CHANNEL_NAME=crosschain

./bin/configtxgen -profile ApplicationGenesis -outputBlock ./artifacts/${CHANNEL_NAME}.block -channelID ${CHANNEL_NAME}