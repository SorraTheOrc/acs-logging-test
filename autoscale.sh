#!/bin/bash

# Demonstrate the scaling up and down of analysers in response to the
# length of the queue.

docker-compose stop
docker-compose rm

clear
echo "Starting one producer and ten analyzer"
echo "======================================================================================="
echo ""
docker-compose scale producer=1
docker-compose scale analyzer=10
docker-compose up -d 
docker-compose ps

echo ""
read -p "Press [Enter] key to see the effect on the queue"
clear

echo "Output the status of the queue every 5 seconds"
echo "======================================================================================="
for i in {1..3}
do
    docker run -e ACS_LOGGING_QUEUE_TYPE=AzureStorageQueue rgardler/acs-logging-test-cli:tr22 summary
    echo ""
    docker-compose ps
    echo "======================================================================================="
    echo ""
    sleep 5
done

echo "Notice how a number of the analyzers have stopped (queue length went to 0)"
echo "But, queue is starting to grow again"
read -p "Press [Enter] key to turn on an auto-scaling algorithm"
clear 

for i in {1..10}
do
    length=$(docker run -e ACS_LOGGING_QUEUE_TYPE=AzureStorageQueue rgardler/acs-logging-test-cli:tr22 length)

    echo ""

    if [ "$length" -gt 50 ]
    then
	echo "Queue is too long ($length), scale up"
	docker-compose scale analyzer=10
    else 
	echo "Queue is an acceptable length ($length)"
    fi
    docker-compose ps
    echo "======================================================================================="
    echo ""
    sleep 5
done