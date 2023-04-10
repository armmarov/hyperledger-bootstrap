# Script for Hyperledger Setup

## Introduction

The script has been created based on the Hyperledger version 2.4.7. Hence, all the binary, docker (peer and orderer) will be reflected to the specific 2.4.7 version. We set up the Hyperledger structure to have 3 CA servers, 3 Peer nodes and 3 Orderer nodes. The CA servers contain main CA for DUMMY (ca-dummy), CA for Orderer (ca-dummy-orderer) and separate CA for TLS. 

## Architecture

![alt text](reference/architecture.PNG "Deployment Architecture")


## Pre-requisite

1. Before continue, make sure you already installed the docker, docker-compose, build-essential, lbzip2, golang and jq package in your environment.

```
Refer to https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-22-04

sudo apt update
sudo apt-get install build-essential -y
sudo apt-get install lbzip2 -y
sudo apt-get install jq -y
sudo apt install golang-go - y
```

2. Set host by opening the /etc/hosts file and add the following records
```
127.0.0.1 peer1.dummy.com
127.0.0.1 peer2.dummy.com
127.0.0.1 peer3.dummy.com
127.0.0.1 orderer1.dummy.com
127.0.0.1 orderer2.dummy.com
127.0.0.1 orderer3.dummy.com
```


3. Only for arm64
Install the package library
```
sudo apt install musl
```

## Untar the binary

1. For amd64 architecture

```
cat tool/amd64-2_4_7/bin.tar.bz2.parta* > bin.tar.gz
tar -xvf bin.tar.gz
```

2. For arm64 architecture

```
cat tool/arm64-2_4_6/bin.tar.bz2.parta* > bin.tar.gz
tar -xvf bin.tar.gz
```

## Change organization
Open the scripts/change-org.sh and rename the organization/peer/orderer name.
Run the following command
```
./scripts/change-org.sh
```

## Update Makefile for arm64 case
Comment out the amd64 parameter and comment out arm64

```
## For amd64
# export DOCKER_VERSION=2.4.7
# export DOCKER_CLI=hyperledger/fabric-tools:${DOCKER_VERSION}
# export DOCKER_CA=hyperledger/fabric-ca:latest
# export DOCKER_PEER=hyperledger/fabric-peer:${DOCKER_VERSION}
# export DOCKER_COUCHDB=hyperledger/fabric-couchdb:latest
# export DOCKER_ORDERER=hyperledger/fabric-orderer:${DOCKER_VERSION}
# export DOCKER_CCENV=hyperledger/fabric-ccenv:${DOCKER_VERSION}
# export DOCKER_BASEOS=hyperledger/fabric-baseos:${DOCKER_VERSION}
# export DOCKER_TOOL=hyperledger/fabric-tools:${DOCKER_VERSION}

## For arm64
export DOCKER_VERSION=2.4.6
export DOCKER_CLI=bswamina/fabric-tools:${DOCKER_VERSION}
export DOCKER_CA=busan15/fabric-ca:latest
export DOCKER_PEER=bswamina/fabric-peer:${DOCKER_VERSION}
export DOCKER_COUCHDB=busan15/fabric-couchdb:latest
export DOCKER_ORDERER=bswamina/fabric-orderer:${DOCKER_VERSION}
export DOCKER_CCENV=bswamina/fabric-ccenv:${DOCKER_VERSION}
export DOCKER_BASEOS=bswamina/fabric-baseos:${DOCKER_VERSION}
export DOCKER_TOOL=bswamina/fabric-tools:${DOCKER_VERSION}
```

## Run makefile
```
make all
```

## To clean previous deployment
```
make clean
```

## To add new organization


### Add at old /etc/hosts (3.0.51.82 is the new org IP)
```
3.0.51.82 peer1.armmarov.com
3.0.51.82 peer2.armmarov.com
3.0.51.82 peer3.armmarov.com
3.0.51.82 orderer1.armmarov.com
3.0.51.82 orderer2.armmarov.com
3.0.51.82 orderer3.armmarov.com
```

### Add at new org /etc/hosts (18.140.114.87 is the old IP)
```
18.140.114.87 peer1.dummy.com
18.140.114.87 peer2.dummy.com
18.140.114.87 peer3.dummy.com
18.140.114.87 orderer1.dummy.com
18.140.114.87 orderer2.dummy.com
18.140.114.87 orderer3.dummy.com

```

### Copy tlsca from old server to new server
```
Eg)
scp -i <SERVER_KEY> ubuntu@<SERVER_IP>:<ROOT_DIR>/ca-repo/fabric-ca-client/orderer/tlsca/tlsca.orderer.com-cert.pem .
scp -i <SERVER_KEY> tlsca.orderer.com-cert.pem  ubuntu@<SERVER_IP>:<ROOT_DIR>/temp/

```

### Add new organization to the channel
```
# From old organization, fetch the config_block.pb
./script/new-org-add.sh peer1 fetch

# Share the config_block.pb to the new org server, run modify
./script/new-org-add.sh peer1 modify

# Sign by new org
./script/new-org-add.sh peer1 sign

# Move the generated pb to old organization, sign
./script/new-org-add.sh peer1 sign

# Update the channel
./script/new-org-add.sh peer1 update
```

### Join peer to channel
```
# From new organization, fetch the config_block.pb
./script/new-org-join-channel.sh peer1 fetch

# Join peer1 to channel
./script/new-org-join-channel.sh peer1 join

# Join peer2 to channel
./script/new-org-join-channel.sh peer2 join

# Join peer3 to channel
./script/new-org-join-channel.sh peer3 join
```

### Set anchor peer
```
# From new organization
./script/new-org-set-anchor-peer.sh peer1
```

### Install chaincode
```
# From new organization
Follow the same step, but need to make sure the approve is based on policy
```


