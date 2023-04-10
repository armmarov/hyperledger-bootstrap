#!/bin/bash

WORKDIR=${PWD}

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $7)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${PEER_HOST}/$2/" \
        -e "s/\${PEER_PORT}/$3/" \
        -e "s#\${PEER_PEM}#$PP#" \
        -e "s/\${CA_HOST}/$5/" \
        -e "s/\${CA_PORT}/$6/" \
        -e "s#\${CA_PEM}#$CP#" \
        -e "s/\${CA_NAME}/$8/" \
        ${WORKDIR}/scripts/ccp-template/ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $7)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${PEER_HOST}/$2/" \
        -e "s/\${PEER_PORT}/$3/" \
        -e "s#\${PEER_PEM}#$PP#" \
        -e "s/\${CA_HOST}/$5/" \
        -e "s/\${CA_PORT}/$6/" \
        -e "s#\${CA_PEM}#$CP#" \
        -e "s/\${CA_NAME}/$8/" \
        ${WORKDIR}/scripts/ccp-template/ccp-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

ORG=Dummy

PEER_HOST=peer1.dummy.com
PEER_PORT=6051
PEER_PEM=${WORKDIR}/ca-repo/fabric-ca-client/dummy/tlsca/tlsca.dummy.com-cert.pem

CA_HOST=ca.dummy.com
CA_PORT=7054
CA_PEM=${WORKDIR}/ca-repo/fabric-ca-client/dummy/ca/ca.dummy.com-cert.pem
CA_NAME=ca-dummy

echo "$(json_ccp $ORG $PEER_HOST $PEER_PORT $PEER_PEM $CA_HOST $CA_PORT $CA_PEM $CA_NAME)" > ${WORKDIR}/ca-repo/clients/$1/connection-dummy.json
echo "$(yaml_ccp $ORG $PEER_HOST $PEER_PORT $PEER_PEM $CA_HOST $CA_PORT $CA_PEM $CA_NAME)" > ${WORKDIR}/ca-repo/clients/$1/connection-dummy.yaml
