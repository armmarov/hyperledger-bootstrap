#!/bin/bash

while sleep 600; 
do
	sensor="Temperature Sensor"
	value=`seq 25 .1 32 | shuf | head -n1`

	data='{"sensor":"'${sensor}'","type":"", "value":"'${value}'", "unit":"degree"}'

	echo $data

	curl -X POST -H "Authorization: Bearer 61309e2e-f1dc-41d5-aeaa-2218ec0bfd84" \
		-H "Content-Type: application/json" \
		-d "$data" \
		http://127.0.0.1:8001/hl/sensor/send-data

	echo ""

done
