.PHONY: install-ca

export COMPOSE_PROJECT_NAME=dummy

export WORKDIR:=${PWD}
export FABRIC_CFG_PATH:=${WORKDIR}/config
export CHANNEL_NAME:=crosschain

## For amd64
export DOCKER_VERSION=2.4.7
export DOCKER_CLI=hyperledger/fabric-tools:${DOCKER_VERSION}
export DOCKER_CA=hyperledger/fabric-ca:latest
export DOCKER_PEER=hyperledger/fabric-peer:${DOCKER_VERSION}
export DOCKER_COUCHDB=hyperledger/fabric-couchdb:latest
export DOCKER_ORDERER=hyperledger/fabric-orderer:${DOCKER_VERSION}
export DOCKER_CCENV=hyperledger/fabric-ccenv:${DOCKER_VERSION}
export DOCKER_BASEOS=hyperledger/fabric-baseos:${DOCKER_VERSION}
export DOCKER_TOOL=hyperledger/fabric-tools:${DOCKER_VERSION}

## For arm64
# export DOCKER_VERSION=2.4.6
# export DOCKER_CLI=bswamina/fabric-tools:${DOCKER_VERSION}
# export DOCKER_CA=busan15/fabric-ca:latest
# export DOCKER_PEER=bswamina/fabric-peer:${DOCKER_VERSION}
# export DOCKER_COUCHDB=busan15/fabric-couchdb:latest
# export DOCKER_ORDERER=bswamina/fabric-orderer:${DOCKER_VERSION}
# export DOCKER_CCENV=bswamina/fabric-ccenv:${DOCKER_VERSION}
# export DOCKER_BASEOS=bswamina/fabric-baseos:${DOCKER_VERSION}
# export DOCKER_TOOL=bswamina/fabric-tools:${DOCKER_VERSION}

export CA_TLS_CLIENT_PORT=8054
export CA_TLS_CLIENT_NAME=ca-tls
export CA_TLS_CLIENT_URL=https://dummy-tls-superadmin:X2555pw4x@localhost:${CA_TLS_CLIENT_PORT}
export CA_TLS_CLIENT_HOME=${WORKDIR}/ca-repo/fabric-ca-client/tlsca
export CA_TLS_CLIENT_TLS=${WORKDIR}/ca-repo/fabric-ca-server/tlsca/ca-cert.pem

export DUMMY_CLIENT_PORT=7054
export DUMMY_CLIENT_NAME=ca-dummy
export DUMMY_CLIENT_URL=https://dummy-superadmin:X2334pw20@localhost:${DUMMY_CLIENT_PORT}
export DUMMY_CLIENT_HOME=${WORKDIR}/ca-repo/fabric-ca-client/dummy
export DUMMY_CLIENT_TLS=${WORKDIR}/ca-repo/fabric-ca-server/dummy/ca-cert.pem

export ORDERER_CLIENT_PORT=9054
export ORDERER_CLIENT_NAME=ca-dummy-orderer
export ORDERER_CLIENT_URL=https://dummy-orderer-superadmin:X2003pw2x@localhost:${ORDERER_CLIENT_PORT}
export ORDERER_CLIENT_HOME=${WORKDIR}/ca-repo/fabric-ca-client/orderer
export ORDERER_CLIENT_TLS=${WORKDIR}/ca-repo/fabric-ca-server/orderer/ca-cert.pem

export DUMMY_ADMIN_USERNAME=dummy-admin
export DUMMY_ADMIN_PASSWORD=AX34453
export DUMMY_ADMIN_HOME=${WORKDIR}/ca-repo/admin

export ORDERER_ADMIN_USERNAME=dummy-admin
export ORDERER_ADMIN_PASSWORD=AX34223
export ORDERER_ADMIN_HOME=${WORKDIR}/ca-repo/orderer-admin

export ORDERER_ORDERER1_USERNAME=dummy-orderer1
export ORDERER_ORDERER1_PASSWORD=AX31123
export ORDERER_ORDERER1_HOME=${WORKDIR}/ca-repo/orderers/orderer1

export ORDERER_ORDERER2_USERNAME=dummy-orderer2
export ORDERER_ORDERER2_PASSWORD=AX31111
export ORDERER_ORDERER2_HOME=${WORKDIR}/ca-repo/orderers/orderer2

export ORDERER_ORDERER3_USERNAME=dummy-orderer3
export ORDERER_ORDERER3_PASSWORD=AX31553
export ORDERER_ORDERER3_HOME=${WORKDIR}/ca-repo/orderers/orderer3

export DUMMY_PEER1_USERNAME=dummy-peer1
export DUMMY_PEER1_PASSWORD=CAV23FF
export DUMMY_PEER1_HOME=${WORKDIR}/ca-repo/peers/peer1

export DUMMY_PEER2_USERNAME=dummy-peer2
export DUMMY_PEER2_PASSWORD=CAN92873
export DUMMY_PEER2_HOME=${WORKDIR}/ca-repo/peers/peer2

export DUMMY_PEER3_USERNAME=dummy-peer3
export DUMMY_PEER3_PASSWORD=TAJ3432
export DUMMY_PEER3_HOME=${WORKDIR}/ca-repo/peers/peer3

pull-docker-image:
	docker pull ${DOCKER_TOOL}
	docker pull ${DOCKER_PEER}
	docker pull ${DOCKER_ORDERER}
	docker pull ${DOCKER_CCENV}
	docker pull ${DOCKER_BASEOS}
	docker pull ${DOCKER_CA}
	docker pull ${DOCKER_COUCHDB}

install-ca:
	echo "##### Bringing up CA dockers #####"
	docker-compose -f docker/docker-compose-ca.yaml up -d

install-peer:
	echo "##### Bringing up PEER dockers #####"
	docker-compose -f docker/docker-compose-peer.yaml up -d

install-orderer:
	echo "##### Bringing up ORDERER dockers #####"
	docker-compose -f docker/docker-compose-orderer.yaml up -d

install-cli:
	echo "##### Bringing up CLI dockers #####"
	docker-compose -f docker/docker-compose-cli.yaml up -d


########## TLS CA Enrollment and Registration

enroll-ca-tls-client:
	echo "##### Enrol CA-TLS Client #####"
	export FABRIC_CA_CLIENT_HOME=${CA_TLS_CLIENT_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${CA_TLS_CLIENT_TLS} && \
	./bin/fabric-ca-client enroll -u ${CA_TLS_CLIENT_URL} --caname ${CA_TLS_CLIENT_NAME} -M "$${FABRIC_CA_CLIENT_HOME}/msp"

create-ca-tls-client: enroll-ca-tls-client


########## ORDERER ORG Enrollment and Registration

enroll-ca-orderer-client:
	echo "##### Enrol CA ORDERER Client #####"
	export FABRIC_CA_CLIENT_HOME=${ORDERER_CLIENT_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${ORDERER_CLIENT_TLS} && \
	./bin/fabric-ca-client enroll -u ${ORDERER_CLIENT_URL} --caname ${ORDERER_CLIENT_NAME} -M "$${FABRIC_CA_CLIENT_HOME}/msp" && \
	cp ./config/nodeous-orderer-config.yaml $${FABRIC_CA_CLIENT_HOME}/msp/config.yaml && \
	mkdir $${FABRIC_CA_CLIENT_HOME}/msp/tlscacerts && \
	cp ${CA_TLS_CLIENT_TLS} $${FABRIC_CA_CLIENT_HOME}/msp/tlscacerts/tlsca.orderer.com-cert.pem && \
	mkdir $${FABRIC_CA_CLIENT_HOME}/tlsca && \
	cp ${CA_TLS_CLIENT_TLS} $${FABRIC_CA_CLIENT_HOME}/tlsca/tlsca.orderer.com-cert.pem

create-ca-orderer-client: enroll-ca-orderer-client


########## DUMMY ORG Enrollment and Registration

enroll-ca-dummy-client:
	echo "##### Enrol CA DUMMY Client #####"
	export FABRIC_CA_CLIENT_HOME=${DUMMY_CLIENT_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${DUMMY_CLIENT_TLS} && \
	./bin/fabric-ca-client enroll -u ${DUMMY_CLIENT_URL} --caname ${DUMMY_CLIENT_NAME} -M "$${FABRIC_CA_CLIENT_HOME}/msp" && \
	cp ./config/nodeous-config.yaml $${FABRIC_CA_CLIENT_HOME}/msp/config.yaml && \
	mkdir $${FABRIC_CA_CLIENT_HOME}/msp/tlscacerts && \
	cp ${CA_TLS_CLIENT_TLS} $${FABRIC_CA_CLIENT_HOME}/msp/tlscacerts/tlsca.dummy.com-cert.pem && \
	mkdir $${FABRIC_CA_CLIENT_HOME}/tlsca && \
	cp ${CA_TLS_CLIENT_TLS} $${FABRIC_CA_CLIENT_HOME}/tlsca/tlsca.dummy.com-cert.pem && \
	mkdir $${FABRIC_CA_CLIENT_HOME}/ca && \
	cp ${CA_TLS_CLIENT_TLS} $${FABRIC_CA_CLIENT_HOME}/ca/ca.dummy.com-cert.pem

create-ca-dummy-client: enroll-ca-dummy-client

########## DUMMY ORG Admin Enrollment and Registration

register-ca-admin-msp:
	echo "##### Register DUMMY Admin MSP #####"
	export FABRIC_CA_CLIENT_HOME=${DUMMY_CLIENT_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${DUMMY_CLIENT_TLS} && \
	./bin/fabric-ca-client register --caname ${DUMMY_CLIENT_NAME} --id.name ${DUMMY_ADMIN_USERNAME} --id.secret ${DUMMY_ADMIN_PASSWORD} --id.type admin

# register-ca-admin-tls:
# 	export FABRIC_CA_CLIENT_HOME=${CA_TLS_CLIENT_HOME} && \
# 	export FABRIC_CA_CLIENT_TLS_CERTFILES=${CA_TLS_CLIENT_TLS} && \
# 	./bin/fabric-ca-client register --caname ${CA_TLS_CLIENT_NAME} --id.name ${DUMMY_ADMIN_USERNAME} --id.secret ${DUMMY_ADMIN_PASSWORD} --id.type admin

enroll-ca-admin-msp:
	echo "##### Enroll DUMMY Admin MSP #####"
	export FABRIC_CA_CLIENT_HOME=${DUMMY_ADMIN_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${DUMMY_CLIENT_TLS} && \
	./bin/fabric-ca-client enroll -u https://${DUMMY_ADMIN_USERNAME}:${DUMMY_ADMIN_PASSWORD}@localhost:${DUMMY_CLIENT_PORT} --caname ${DUMMY_CLIENT_NAME} -M "$${FABRIC_CA_CLIENT_HOME}/msp" && \
	cp ./config/nodeous-config.yaml $${FABRIC_CA_CLIENT_HOME}/msp/config.yaml

# enroll-ca-admin-tls:
# 	export FABRIC_CA_CLIENT_HOME=${DUMMY_ADMIN_HOME} && \
# 	export FABRIC_CA_CLIENT_TLS_CERTFILES=${DUMMY_CLIENT_TLS} && \
# 	./bin/fabric-ca-client enroll -u https://${DUMMY_ADMIN_USERNAME}:${DUMMY_ADMIN_PASSWORD}@localhost:${CA_TLS_CLIENT_PORT} --caname ${CA_TLS_CLIENT_NAME} -M "$${FABRIC_CA_CLIENT_HOME}/tls" --enrollment.profile tls && \
# 	cp $${FABRIC_CA_CLIENT_HOME}/tls/tlscacerts/* $${FABRIC_CA_CLIENT_HOME}/tls/ca.crt && \
# 	cp $${FABRIC_CA_CLIENT_HOME}/tls/signcerts/* $${FABRIC_CA_CLIENT_HOME}/tls/server.crt && \
# 	cp $${FABRIC_CA_CLIENT_HOME}/tls/keystore/* $${FABRIC_CA_CLIENT_HOME}/tls/server.key

create-ca-admin: register-ca-admin-msp enroll-ca-admin-msp

########## ORDERER ORG Admin Enrollment and Registration

register-ca-orderer-admin-msp:
	echo "##### Register ORDERER Admin MSP #####"
	export FABRIC_CA_CLIENT_HOME=${ORDERER_CLIENT_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${ORDERER_CLIENT_TLS} && \
	./bin/fabric-ca-client register --caname ${ORDERER_CLIENT_NAME} --id.name ${ORDERER_ADMIN_USERNAME} --id.secret ${ORDERER_ADMIN_PASSWORD} --id.type admin --id.attrs "hf.Registrar.Roles=client,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=true:ecert,abac.init=true:ecert"

# register-ca-orderer-admin-tls:
# 	export FABRIC_CA_CLIENT_HOME=${CA_TLS_CLIENT_HOME} && \
# 	export FABRIC_CA_CLIENT_TLS_CERTFILES=${CA_TLS_CLIENT_TLS} && \
# 	./bin/fabric-ca-client register --caname ${CA_TLS_CLIENT_NAME} --id.name ${ORDERER_ADMIN_USERNAME} --id.secret ${ORDERER_ADMIN_PASSWORD} --id.type admin --id.attrs "hf.Registrar.Roles=client,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=true:ecert,abac.init=true:ecert"

enroll-ca-orderer-admin-msp:
	echo "##### Enroll ORDERER Admin MSP #####"
	export FABRIC_CA_CLIENT_HOME=${ORDERER_ADMIN_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${ORDERER_CLIENT_TLS} && \
	./bin/fabric-ca-client enroll -u https://${ORDERER_ADMIN_USERNAME}:${ORDERER_ADMIN_PASSWORD}@localhost:${ORDERER_CLIENT_PORT} --caname ${ORDERER_CLIENT_NAME} -M "$${FABRIC_CA_CLIENT_HOME}/msp" && \
	cp ./config/nodeous-orderer-config.yaml $${FABRIC_CA_CLIENT_HOME}/msp/config.yaml

# enroll-ca-orderer-admin-tls:
# 	export FABRIC_CA_CLIENT_HOME=${ORDERER_ADMIN_HOME} && \
# 	export FABRIC_CA_CLIENT_TLS_CERTFILES=${CA_TLS_CLIENT_TLS} && \
# 	./bin/fabric-ca-client enroll -u https://${ORDERER_ADMIN_USERNAME}:${ORDERER_ADMIN_PASSWORD}@localhost:${CA_TLS_CLIENT_PORT} --caname ${CA_TLS_CLIENT_NAME} -M "$${FABRIC_CA_CLIENT_HOME}/tls" --enrollment.profile tls && \
# 	cp $${FABRIC_CA_CLIENT_HOME}/tls/tlscacerts/* $${FABRIC_CA_CLIENT_HOME}/tls/ca.crt && \
# 	cp $${FABRIC_CA_CLIENT_HOME}/tls/signcerts/* $${FABRIC_CA_CLIENT_HOME}/tls/server.crt && \
# 	cp $${FABRIC_CA_CLIENT_HOME}/tls/keystore/* $${FABRIC_CA_CLIENT_HOME}/tls/server.key

create-ca-orderer-admin: register-ca-orderer-admin-msp enroll-ca-orderer-admin-msp

########## ORDERER ORG Orderer1 Enrollment and Registration

register-ca-orderer-orderer1-msp:
	echo "##### Register ORDERER1 MSP #####"
	export FABRIC_CA_CLIENT_HOME=${ORDERER_CLIENT_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${ORDERER_CLIENT_TLS} && \
	./bin/fabric-ca-client register --caname ${ORDERER_CLIENT_NAME} --id.name ${ORDERER_ORDERER1_USERNAME} --id.secret ${ORDERER_ORDERER1_PASSWORD} --id.type orderer

register-ca-orderer-orderer1-tls:
	echo "##### Register ORDERER1 TLS #####"
	export FABRIC_CA_CLIENT_HOME=${CA_TLS_CLIENT_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${CA_TLS_CLIENT_TLS} && \
	./bin/fabric-ca-client register --caname ${CA_TLS_CLIENT_NAME} --id.name ${ORDERER_ORDERER1_USERNAME} --id.secret ${ORDERER_ORDERER1_PASSWORD} --id.type orderer

enroll-ca-orderer-orderer1-msp:
	echo "##### Enroll ORDERER1 MSP #####"
	export FABRIC_CA_CLIENT_HOME=${ORDERER_ORDERER1_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${ORDERER_CLIENT_TLS} && \
	./bin/fabric-ca-client enroll -u https://${ORDERER_ORDERER1_USERNAME}:${ORDERER_ORDERER1_PASSWORD}@localhost:${ORDERER_CLIENT_PORT} --caname ${ORDERER_CLIENT_NAME} -M "$${FABRIC_CA_CLIENT_HOME}/msp" && \
	cp ./config/nodeous-orderer-config.yaml $${FABRIC_CA_CLIENT_HOME}/msp/config.yaml && \
	mkdir $${FABRIC_CA_CLIENT_HOME}/msp/admincerts && \
	cp ${ORDERER_ADMIN_HOME}/msp/signcerts/cert.pem $${FABRIC_CA_CLIENT_HOME}/msp/admincerts/orderer-admin-cert.pem

enroll-ca-orderer-orderer1-tls:
	echo "##### Enroll ORDERER1 TLS #####"
	export FABRIC_CA_CLIENT_HOME=${ORDERER_ORDERER1_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${CA_TLS_CLIENT_TLS} && \
	./bin/fabric-ca-client enroll -u https://${ORDERER_ORDERER1_USERNAME}:${ORDERER_ORDERER1_PASSWORD}@localhost:${CA_TLS_CLIENT_PORT} --caname ${CA_TLS_CLIENT_NAME} -M "$${FABRIC_CA_CLIENT_HOME}/tls" --enrollment.profile tls --csr.hosts localhost --csr.hosts orderer1.dummy.com && \
	cp $${FABRIC_CA_CLIENT_HOME}/tls/tlscacerts/* $${FABRIC_CA_CLIENT_HOME}/tls/ca.crt && \
	cp $${FABRIC_CA_CLIENT_HOME}/tls/signcerts/* $${FABRIC_CA_CLIENT_HOME}/tls/server.crt && \
	cp $${FABRIC_CA_CLIENT_HOME}/tls/keystore/* $${FABRIC_CA_CLIENT_HOME}/tls/server.key && \
	mkdir $${FABRIC_CA_CLIENT_HOME}/msp/tlscacerts && \
	cp $${FABRIC_CA_CLIENT_HOME}/tls/tlscacerts/* $${FABRIC_CA_CLIENT_HOME}/msp/tlscacerts/tlsca.orderer.com-cert.pem

create-ca-orderer-orderer1: register-ca-orderer-orderer1-msp register-ca-orderer-orderer1-tls enroll-ca-orderer-orderer1-msp enroll-ca-orderer-orderer1-tls

########## ORDERER ORG Orderer2 Enrollment and Registration

register-ca-orderer-orderer2-msp:
	export FABRIC_CA_CLIENT_HOME=${ORDERER_CLIENT_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${ORDERER_CLIENT_TLS} && \
	./bin/fabric-ca-client register --caname ${ORDERER_CLIENT_NAME} --id.name ${ORDERER_ORDERER2_USERNAME} --id.secret ${ORDERER_ORDERER2_PASSWORD} --id.type orderer

register-ca-orderer-orderer2-tls:
	export FABRIC_CA_CLIENT_HOME=${CA_TLS_CLIENT_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${CA_TLS_CLIENT_TLS} && \
	./bin/fabric-ca-client register --caname ${CA_TLS_CLIENT_NAME} --id.name ${ORDERER_ORDERER2_USERNAME} --id.secret ${ORDERER_ORDERER2_PASSWORD} --id.type orderer

enroll-ca-orderer-orderer2-msp:
	export FABRIC_CA_CLIENT_HOME=${ORDERER_ORDERER2_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${ORDERER_CLIENT_TLS} && \
	./bin/fabric-ca-client enroll -u https://${ORDERER_ORDERER2_USERNAME}:${ORDERER_ORDERER2_PASSWORD}@localhost:${ORDERER_CLIENT_PORT} --caname ${ORDERER_CLIENT_NAME} -M "$${FABRIC_CA_CLIENT_HOME}/msp" && \
	cp ./config/nodeous-orderer-config.yaml $${FABRIC_CA_CLIENT_HOME}/msp/config.yaml && \
	mkdir $${FABRIC_CA_CLIENT_HOME}/msp/admincerts && \
	cp ${ORDERER_ADMIN_HOME}/msp/signcerts/cert.pem $${FABRIC_CA_CLIENT_HOME}/msp/admincerts/orderer-admin-cert.pem

enroll-ca-orderer-orderer2-tls:
	export FABRIC_CA_CLIENT_HOME=${ORDERER_ORDERER2_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${CA_TLS_CLIENT_TLS} && \
	./bin/fabric-ca-client enroll -u https://${ORDERER_ORDERER2_USERNAME}:${ORDERER_ORDERER2_PASSWORD}@localhost:${CA_TLS_CLIENT_PORT} --caname ${CA_TLS_CLIENT_NAME} -M "$${FABRIC_CA_CLIENT_HOME}/tls" --enrollment.profile tls --csr.hosts localhost --csr.hosts orderer2.dummy.com && \
	cp $${FABRIC_CA_CLIENT_HOME}/tls/tlscacerts/* $${FABRIC_CA_CLIENT_HOME}/tls/ca.crt && \
	cp $${FABRIC_CA_CLIENT_HOME}/tls/signcerts/* $${FABRIC_CA_CLIENT_HOME}/tls/server.crt && \
	cp $${FABRIC_CA_CLIENT_HOME}/tls/keystore/* $${FABRIC_CA_CLIENT_HOME}/tls/server.key && \
	mkdir $${FABRIC_CA_CLIENT_HOME}/msp/tlscacerts && \
	cp $${FABRIC_CA_CLIENT_HOME}/tls/tlscacerts/* $${FABRIC_CA_CLIENT_HOME}/msp/tlscacerts/tlsca.orderer.com-cert.pem

create-ca-orderer-orderer2: register-ca-orderer-orderer2-msp register-ca-orderer-orderer2-tls enroll-ca-orderer-orderer2-msp enroll-ca-orderer-orderer2-tls

########## ORDERER ORG Orderer3 Enrollment and Registration

register-ca-orderer-orderer3-msp:
	export FABRIC_CA_CLIENT_HOME=${ORDERER_CLIENT_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${ORDERER_CLIENT_TLS} && \
	./bin/fabric-ca-client register --caname ${ORDERER_CLIENT_NAME} --id.name ${ORDERER_ORDERER3_USERNAME} --id.secret ${ORDERER_ORDERER3_PASSWORD} --id.type orderer

register-ca-orderer-orderer3-tls:
	export FABRIC_CA_CLIENT_HOME=${CA_TLS_CLIENT_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${CA_TLS_CLIENT_TLS} && \
	./bin/fabric-ca-client register --caname ${CA_TLS_CLIENT_NAME} --id.name ${ORDERER_ORDERER3_USERNAME} --id.secret ${ORDERER_ORDERER3_PASSWORD} --id.type orderer

enroll-ca-orderer-orderer3-msp:
	export FABRIC_CA_CLIENT_HOME=${ORDERER_ORDERER3_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${ORDERER_CLIENT_TLS} && \
	./bin/fabric-ca-client enroll -u https://${ORDERER_ORDERER3_USERNAME}:${ORDERER_ORDERER3_PASSWORD}@localhost:${ORDERER_CLIENT_PORT} --caname ${ORDERER_CLIENT_NAME} -M "$${FABRIC_CA_CLIENT_HOME}/msp" && \
	cp ./config/nodeous-orderer-config.yaml $${FABRIC_CA_CLIENT_HOME}/msp/config.yaml && \
	mkdir $${FABRIC_CA_CLIENT_HOME}/msp/admincerts && \
	cp ${ORDERER_ADMIN_HOME}/msp/signcerts/cert.pem $${FABRIC_CA_CLIENT_HOME}/msp/admincerts/orderer-admin-cert.pem

enroll-ca-orderer-orderer3-tls:
	export FABRIC_CA_CLIENT_HOME=${ORDERER_ORDERER3_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${CA_TLS_CLIENT_TLS} && \
	./bin/fabric-ca-client enroll -u https://${ORDERER_ORDERER3_USERNAME}:${ORDERER_ORDERER3_PASSWORD}@localhost:${CA_TLS_CLIENT_PORT} --caname ${CA_TLS_CLIENT_NAME} -M "$${FABRIC_CA_CLIENT_HOME}/tls" --enrollment.profile tls --csr.hosts localhost --csr.hosts orderer3.dummy.com && \
	cp $${FABRIC_CA_CLIENT_HOME}/tls/tlscacerts/* $${FABRIC_CA_CLIENT_HOME}/tls/ca.crt && \
	cp $${FABRIC_CA_CLIENT_HOME}/tls/signcerts/* $${FABRIC_CA_CLIENT_HOME}/tls/server.crt && \
	cp $${FABRIC_CA_CLIENT_HOME}/tls/keystore/* $${FABRIC_CA_CLIENT_HOME}/tls/server.key && \
	mkdir $${FABRIC_CA_CLIENT_HOME}/msp/tlscacerts && \
	cp $${FABRIC_CA_CLIENT_HOME}/tls/tlscacerts/* $${FABRIC_CA_CLIENT_HOME}/msp/tlscacerts/tlsca.orderer.com-cert.pem

create-ca-orderer-orderer3: register-ca-orderer-orderer3-msp register-ca-orderer-orderer3-tls enroll-ca-orderer-orderer3-msp enroll-ca-orderer-orderer3-tls

########## DUMMY ORG Peer1 Enrollment and Registration

register-ca-peer1-msp:
	export FABRIC_CA_CLIENT_HOME=${DUMMY_CLIENT_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${DUMMY_CLIENT_TLS} && \
	./bin/fabric-ca-client register --caname ${DUMMY_CLIENT_NAME} --id.name ${DUMMY_PEER1_USERNAME} --id.secret ${DUMMY_PEER1_PASSWORD} --id.type peer

register-ca-peer1-tls:
	export FABRIC_CA_CLIENT_HOME=${CA_TLS_CLIENT_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${CA_TLS_CLIENT_TLS} && \
	./bin/fabric-ca-client register --caname ${CA_TLS_CLIENT_NAME} --id.name ${DUMMY_PEER1_USERNAME} --id.secret ${DUMMY_PEER1_PASSWORD} --id.type peer

enroll-ca-peer1-msp:
	export FABRIC_CA_CLIENT_HOME=${DUMMY_PEER1_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${DUMMY_CLIENT_TLS} && \
	./bin/fabric-ca-client enroll -u https://${DUMMY_PEER1_USERNAME}:${DUMMY_PEER1_PASSWORD}@localhost:${DUMMY_CLIENT_PORT} --caname ${DUMMY_CLIENT_NAME} -M "$${FABRIC_CA_CLIENT_HOME}/msp" && \
	cp ./config/nodeous-config.yaml $${FABRIC_CA_CLIENT_HOME}/msp/config.yaml && \
	mkdir $${FABRIC_CA_CLIENT_HOME}/msp/admincerts && \
	cp ${DUMMY_ADMIN_HOME}/msp/signcerts/cert.pem $${FABRIC_CA_CLIENT_HOME}/msp/admincerts/dummy-admin-cert.pem

enroll-ca-peer1-tls:
	export FABRIC_CA_CLIENT_HOME=${DUMMY_PEER1_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${CA_TLS_CLIENT_TLS} && \
	./bin/fabric-ca-client enroll -u https://${DUMMY_PEER1_USERNAME}:${DUMMY_PEER1_PASSWORD}@localhost:${CA_TLS_CLIENT_PORT} --caname ${CA_TLS_CLIENT_NAME} -M "$${FABRIC_CA_CLIENT_HOME}/tls" --enrollment.profile tls --csr.hosts localhost --csr.hosts peer1.dummy.com && \
	cp $${FABRIC_CA_CLIENT_HOME}/tls/tlscacerts/* $${FABRIC_CA_CLIENT_HOME}/tls/ca.crt && \
	cp $${FABRIC_CA_CLIENT_HOME}/tls/signcerts/* $${FABRIC_CA_CLIENT_HOME}/tls/server.crt && \
	cp $${FABRIC_CA_CLIENT_HOME}/tls/keystore/* $${FABRIC_CA_CLIENT_HOME}/tls/server.key && \
	mkdir $${FABRIC_CA_CLIENT_HOME}/msp/tlscacerts && \
	cp $${FABRIC_CA_CLIENT_HOME}/tls/tlscacerts/* $${FABRIC_CA_CLIENT_HOME}/msp/tlscacerts/tlsca.dummy.com-cert.pem

create-ca-peer1: register-ca-peer1-msp register-ca-peer1-tls enroll-ca-peer1-msp enroll-ca-peer1-tls

########## DUMMY ORG Peer2 Enrollment and Registration

register-ca-peer2-msp:
	export FABRIC_CA_CLIENT_HOME=${DUMMY_CLIENT_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${DUMMY_CLIENT_TLS} && \
	./bin/fabric-ca-client register --caname ${DUMMY_CLIENT_NAME} --id.name ${DUMMY_PEER2_USERNAME} --id.secret ${DUMMY_PEER2_PASSWORD} --id.type peer

register-ca-peer2-tls:
	export FABRIC_CA_CLIENT_HOME=${CA_TLS_CLIENT_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${CA_TLS_CLIENT_TLS} && \
	./bin/fabric-ca-client register --caname ${CA_TLS_CLIENT_NAME} --id.name ${DUMMY_PEER2_USERNAME} --id.secret ${DUMMY_PEER2_PASSWORD} --id.type peer

enroll-ca-peer2-msp:
	export FABRIC_CA_CLIENT_HOME=${DUMMY_PEER2_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${DUMMY_CLIENT_TLS} && \
	./bin/fabric-ca-client enroll -u https://${DUMMY_PEER2_USERNAME}:${DUMMY_PEER2_PASSWORD}@localhost:${DUMMY_CLIENT_PORT} --caname ${DUMMY_CLIENT_NAME} -M "$${FABRIC_CA_CLIENT_HOME}/msp" && \
	cp ./config/nodeous-config.yaml $${FABRIC_CA_CLIENT_HOME}/msp/config.yaml && \
	mkdir $${FABRIC_CA_CLIENT_HOME}/msp/admincerts && \
	cp ${DUMMY_ADMIN_HOME}/msp/signcerts/cert.pem $${FABRIC_CA_CLIENT_HOME}/msp/admincerts/dummy-admin-cert.pem

enroll-ca-peer2-tls:
	export FABRIC_CA_CLIENT_HOME=${DUMMY_PEER2_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${CA_TLS_CLIENT_TLS} && \
	./bin/fabric-ca-client enroll -u https://${DUMMY_PEER2_USERNAME}:${DUMMY_PEER2_PASSWORD}@localhost:${CA_TLS_CLIENT_PORT} --caname ${CA_TLS_CLIENT_NAME} -M "$${FABRIC_CA_CLIENT_HOME}/tls" --enrollment.profile tls --csr.hosts localhost --csr.hosts peer2.dummy.com && \
	cp $${FABRIC_CA_CLIENT_HOME}/tls/tlscacerts/* $${FABRIC_CA_CLIENT_HOME}/tls/ca.crt && \
	cp $${FABRIC_CA_CLIENT_HOME}/tls/signcerts/* $${FABRIC_CA_CLIENT_HOME}/tls/server.crt && \
	cp $${FABRIC_CA_CLIENT_HOME}/tls/keystore/* $${FABRIC_CA_CLIENT_HOME}/tls/server.key && \
	mkdir $${FABRIC_CA_CLIENT_HOME}/msp/tlscacerts && \
	cp $${FABRIC_CA_CLIENT_HOME}/tls/tlscacerts/* $${FABRIC_CA_CLIENT_HOME}/msp/tlscacerts/tlsca.dummy.com-cert.pem

create-ca-peer2: register-ca-peer2-msp register-ca-peer2-tls enroll-ca-peer2-msp enroll-ca-peer2-tls

########## DUMMY ORG Peer3 Enrollment and Registration

register-ca-peer3-msp:
	export FABRIC_CA_CLIENT_HOME=${DUMMY_CLIENT_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${DUMMY_CLIENT_TLS} && \
	./bin/fabric-ca-client register --caname ${DUMMY_CLIENT_NAME} --id.name ${DUMMY_PEER3_USERNAME} --id.secret ${DUMMY_PEER3_PASSWORD} --id.type peer

register-ca-peer3-tls:
	export FABRIC_CA_CLIENT_HOME=${CA_TLS_CLIENT_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${CA_TLS_CLIENT_TLS} && \
	./bin/fabric-ca-client register --caname ${CA_TLS_CLIENT_NAME} --id.name ${DUMMY_PEER3_USERNAME} --id.secret ${DUMMY_PEER3_PASSWORD} --id.type peer

enroll-ca-peer3-msp:
	export FABRIC_CA_CLIENT_HOME=${DUMMY_PEER3_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${DUMMY_CLIENT_TLS} && \
	./bin/fabric-ca-client enroll -u https://${DUMMY_PEER3_USERNAME}:${DUMMY_PEER3_PASSWORD}@localhost:${DUMMY_CLIENT_PORT} --caname ${DUMMY_CLIENT_NAME} -M "$${FABRIC_CA_CLIENT_HOME}/msp" && \
	cp ./config/nodeous-config.yaml $${FABRIC_CA_CLIENT_HOME}/msp/config.yaml && \
	mkdir $${FABRIC_CA_CLIENT_HOME}/msp/admincerts && \
	cp ${DUMMY_ADMIN_HOME}/msp/signcerts/cert.pem $${FABRIC_CA_CLIENT_HOME}/msp/admincerts/dummy-admin-cert.pem

enroll-ca-peer3-tls:
	export FABRIC_CA_CLIENT_HOME=${DUMMY_PEER3_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${CA_TLS_CLIENT_TLS} && \
	./bin/fabric-ca-client enroll -u https://${DUMMY_PEER3_USERNAME}:${DUMMY_PEER3_PASSWORD}@localhost:${CA_TLS_CLIENT_PORT} --caname ${CA_TLS_CLIENT_NAME} -M "$${FABRIC_CA_CLIENT_HOME}/tls" --enrollment.profile tls --csr.hosts localhost --csr.hosts peer3.dummy.com && \
	cp $${FABRIC_CA_CLIENT_HOME}/tls/tlscacerts/* $${FABRIC_CA_CLIENT_HOME}/tls/ca.crt && \
	cp $${FABRIC_CA_CLIENT_HOME}/tls/signcerts/* $${FABRIC_CA_CLIENT_HOME}/tls/server.crt && \
	cp $${FABRIC_CA_CLIENT_HOME}/tls/keystore/* $${FABRIC_CA_CLIENT_HOME}/tls/server.key && \
	mkdir $${FABRIC_CA_CLIENT_HOME}/msp/tlscacerts && \
	cp $${FABRIC_CA_CLIENT_HOME}/tls/tlscacerts/* $${FABRIC_CA_CLIENT_HOME}/msp/tlscacerts/tlsca.dummy.com-cert.pem

create-ca-peer3: register-ca-peer3-msp register-ca-peer3-tls enroll-ca-peer3-msp enroll-ca-peer3-tls

########## DUMMY ORG Client1 Enrollment and Registration

register-ca-client1-msp:
	export FABRIC_CA_CLIENT_HOME=${DUMMY_CLIENT_HOME} && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${DUMMY_CLIENT_TLS} && \
	./bin/fabric-ca-client register --caname ${DUMMY_CLIENT_NAME} --id.name client1 --id.secret X543123 --id.type client && \
	cp ./config/nodeous-config.yaml $${FABRIC_CA_CLIENT_HOME}/msp/config.yaml

enroll-ca-client1-msp:
	export FABRIC_CA_CLIENT_HOME=${WORKDIR}/ca-repo/clients/client1 && \
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${DUMMY_CLIENT_TLS} && \
	./bin/fabric-ca-client enroll -u https://client1:X543123@localhost:${DUMMY_CLIENT_PORT} --caname ${DUMMY_CLIENT_NAME} -M "$${FABRIC_CA_CLIENT_HOME}/msp" && \
	cp ./config/nodeous-config.yaml $${FABRIC_CA_CLIENT_HOME}/msp/config.yaml 

create-ca-client1: register-ca-client1-msp enroll-ca-client1-msp

########## Logging and Monitoring

install-logging:
	echo "##### Bringing up logging dockers #####"
	cd monitoring/logging/fluentd && \
	docker-compose up -d

install-monitoring:
	echo "##### Bringing up monitoring dockers #####"
	cd monitoring/monitoring && \
	docker-compose up -d

install-explorer:
	echo "##### Bringing up explorer dockers #####"
	cd explorer && \
	docker-compose up -d

clean-docker:
	docker rm -f ca-dummy ca-dummy-orderer ca-tls peer1-db peer1.dummy.com peer2-db peer2.dummy.com peer3-db peer3.dummy.com orderer1.dummy.com orderer2.dummy.com orderer3.dummy.com cli && \
	docker volume rm dummy_orderer1.dummy.com dummy_orderer2.dummy.com dummy_orderer3.dummy.com dummy_peer1.dummy.com dummy_peer2.dummy.com dummy_peer3.dummy.com && \
	sudo rm -rf ${WORKDIR}/ca-repo/fabric-ca-server/* && touch ${WORKDIR}/ca-repo/fabric-ca-server/.gitkeep	

clean-ca-dummy:	
	sudo rm -rf ${WORKDIR}/ca-repo/fabric-ca-client/dummy/* && touch ${WORKDIR}/ca-repo/fabric-ca-client/dummy/.gitkeep && \
	sudo rm -rf ${WORKDIR}/ca-repo/admin/* && touch ${WORKDIR}/ca-repo/admin/.gitkeep && \
	sudo rm -rf ${WORKDIR}/ca-repo/peers/* && touch ${WORKDIR}/ca-repo/peers/.gitkeep && \
	sudo rm -rf ${WORKDIR}/ca-repo/clients/* && touch ${WORKDIR}/ca-repo/clients/.gitkeep

clean-ca-orderer:
	sudo rm -rf ${WORKDIR}/ca-repo/fabric-ca-client/orderer/* && touch ${WORKDIR}/ca-repo/fabric-ca-client/orderer/.gitkeep && \
	sudo rm -rf ${WORKDIR}/ca-repo/orderer-admin/* && touch ${WORKDIR}/ca-repo/orderer-admin/.gitkeep && \
	sudo rm -rf ${WORKDIR}/ca-repo/orderers/* && touch ${WORKDIR}/ca-repo/orderers/.gitkeep

clean-ca-tls:
	sudo rm -rf ${WORKDIR}/ca-repo/fabric-ca-client/tlsca/* && touch ${WORKDIR}/ca-repo/fabric-ca-client/tlsca/.gitkeep

clean-temp-dir:
	sudo rm -rf ${WORKDIR}/temp/* && touch ${WORKDIR}/temp/.gitkeep

create-ca-tls: create-ca-tls-client

create-ca-dummy: create-ca-dummy-client create-ca-admin create-ca-peer1 create-ca-peer2 create-ca-peer3

create-ca-orderer: create-ca-orderer-client create-ca-orderer-admin create-ca-orderer-orderer1 create-ca-orderer-orderer2 create-ca-orderer-orderer3

clean: clean-docker clean-ca-tls clean-ca-dummy clean-ca-orderer clean-artifacts clean-temp-dir

create-ca: create-ca-tls create-ca-orderer create-ca-dummy

install-node: install-peer install-orderer

orderer-join-channel:
	./scripts/orderer-join-channel.sh orderer1
	./scripts/orderer-join-channel.sh orderer2
	./scripts/orderer-join-channel.sh orderer3

peer-join-channel:
	./scripts/peer-join-channel.sh peer1
	./scripts/peer-join-channel.sh peer2
	./scripts/peer-join-channel.sh peer3

set-anchor-peer:
	./scripts/set-anchor-peer.sh peer1

fetch-new-org:
	./scripts/add-new-org.sh peer1 fetch

modify-new-org:
	./scripts/add-new-org.sh peer1 modify

sign-new-org:
	./scripts/add-new-org.sh peer1 sign

update-new-org:
	./scripts/add-new-org.sh peer1 update

add-new-org: fetch-new-org modify-new-org sign-new-org update-new-org

create-genesis:
	./scripts/create-channel.sh

create-ccp:
	./scripts/ccp-template/ccp-generate.sh client1

clean-artifacts:
	sudo rm -rf ${WORKDIR}/artifacts/* && touch ${WORKDIR}/artifacts/.gitkeep

clean-client:
	sudo rm -rf ${WORKDIR}/ca-repo/clients/* && touch ${WORKDIR}/ca-repo/clients/.gitkeep

install-chaincode:
	./scripts/install-cc.sh peer1 package && \
	./scripts/install-cc.sh peer1 install && \
	./scripts/install-cc.sh peer1 approve && \
	./scripts/install-cc.sh peer1 check && \
	./scripts/install-cc.sh peer1 commit && \
	./scripts/install-cc.sh peer1 query-committed && \
	./scripts/install-cc.sh peer1 invoke-init && \
	./scripts/install-cc.sh peer2 install && \
	./scripts/install-cc.sh peer3 install

all:  
	$(MAKE) pull-docker-image
	sleep 2
	$(MAKE) install-ca 
	sleep 2
	$(MAKE) create-ca
	sleep 1
	$(MAKE) install-node
	sleep 1
	$(MAKE) install-cli
	docker ps
	sleep 1
	$(MAKE) create-genesis
	sleep 1
	$(MAKE) orderer-join-channel
	sleep 1
	$(MAKE) peer-join-channel
	sleep 1
	$(MAKE) set-anchor-peer
	sleep 1
	$(MAKE) install-chaincode
	sleep 1
	$(MAKE) create-ca-client1
	sleep 1
	$(MAKE) create-ccp