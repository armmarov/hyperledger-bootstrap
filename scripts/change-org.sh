#!/bin/bash

export org=dummy
export Org=Dummy
export ORG=DUMMY

export peer1=peer1
export Peer1=Peer1
export PEER1=PEER1

export peer2=peer2
export Peer2=Peer2
export PEER2=PEER2

export peer3=peer3
export Peer3=Peer3
export PEER3=PEER3

export orderer1=orderer1
export Orderer1=Orderer1
export ORDERER1=ORDERER1

export orderer2=orderer2
export Orderer2=Orderer2
export ORDERER2=ORDERER2

export orderer3=orderer3
export Orderer3=Orderer3
export ORDERER3=ORDERER3

find . -path ./.git -prune -o -path ./tool -prune -o -type f -exec sed -i 's/dummy/'${org}'/g' {} +
find . -path ./.git -prune -o -path ./tool -prune -o -type f -exec sed -i 's/Dummy/'${Org}'/g' {} +
find . -path ./.git -prune -o -path ./tool -prune -o -type f -exec sed -i 's/DUMMY/'${ORG}'/g' {} +

find . -path ./.git -prune -o -path ./tool -prune -o -type f -exec sed -i 's/peer1/'${peer1}'/g' {} +
find . -path ./.git -prune -o -path ./tool -prune -o -type f -exec sed -i 's/Peer1/'${Peer1}'/g' {} +
find . -path ./.git -prune -o -path ./tool -prune -o -type f -exec sed -i 's/PEER1/'${PEER1}'/g' {} +

find . -path ./.git -prune -o -path ./tool -prune -o -type f -exec sed -i 's/peer2/'${peer2}'/g' {} +
find . -path ./.git -prune -o -path ./tool -prune -o -type f -exec sed -i 's/Peer2/'${Peer2}'/g' {} +
find . -path ./.git -prune -o -path ./tool -prune -o -type f -exec sed -i 's/PEER2/'${PEER2}'/g' {} +

find . -path ./.git -prune -o -path ./tool -prune -o -type f -exec sed -i 's/peer3/'${peer3}'/g' {} +
find . -path ./.git -prune -o -path ./tool -prune -o -type f -exec sed -i 's/Peer3/'${Peer3}'/g' {} +
find . -path ./.git -prune -o -path ./tool -prune -o -type f -exec sed -i 's/PEER3/'${PEER3}'/g' {} +

find . -path ./.git -prune -o -path ./tool -prune -o -type f -exec sed -i 's/orderer1/'${orderer1}'/g' {} +
find . -path ./.git -prune -o -path ./tool -prune -o -type f -exec sed -i 's/Orderer1/'${Orderer1}'/g' {} +
find . -path ./.git -prune -o -path ./tool -prune -o -type f -exec sed -i 's/ORDERER1/'${ORDERER1}'/g' {} +

find . -path ./.git -prune -o -path ./tool -prune -o -type f -exec sed -i 's/orderer2/'${orderer2}'/g' {} +
find . -path ./.git -prune -o -path ./tool -prune -o -type f -exec sed -i 's/Orderer2/'${Orderer2}'/g' {} +
find . -path ./.git -prune -o -path ./tool -prune -o -type f -exec sed -i 's/ORDERER2/'${ORDERER2}'/g' {} +

find . -path ./.git -prune -o -path ./tool -prune -o -type f -exec sed -i 's/orderer3/'${orderer3}'/g' {} +
find . -path ./.git -prune -o -path ./tool -prune -o -type f -exec sed -i 's/Orderer3/'${Orderer3}'/g' {} +
find . -path ./.git -prune -o -path ./tool -prune -o -type f -exec sed -i 's/ORDERER3/'${ORDERER3}'/g' {} +

mv ca-repo/fabric-ca-client/dummy ca-repo/fabric-ca-client/${org}
