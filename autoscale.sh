#!/bin/bash

# Demonstrate the scaling up and down of analysers in response to the
# length of the queue.

SCALE_SET_NAME=swarm-agent-94077C7vmss-0

PRODUCERS=1
MAX_PRODUCERS=20
ANALYZERS=1

STATUS_REPEATS=1
STATUS_DELAY=1

CONTAINER_SCALE_REPEATS=3
CONTAINER_SCALE_DELAY=1

clear
echo "Starting $PRODUCERS producer and $ANALYZERS analyzer"
echo "======================================================================================="
echo ""
docker-compose scale producer=$PRODUCERS
docker-compose scale analyzer=$ANALYZERS
docker-compose up -d 
docker-compose ps

echo ""
read -p "Press [Enter] key to see the effect on the queue"
clear

echo "Output the status of the queue every $STATUS_DELAY seconds"
echo "======================================================================================="
for i in {1..$STATUS_REPEATS}
do
    docker run -it rgardler/acs-logging-test-cli summary
    echo ""
    docker-compose ps
    echo "======================================================================================="
    echo ""
    sleep $STATUS_DELAY
done

echo "Notice how the queue is starting to grow again"
read -p "Press [Enter] key to turn on an auto-scaling algorithm"
clear 

for i in {1..$CONTAINER_SCALE_REPEATS}
do
    length=$(docker run -i rgardler/acs-logging-test-cli length)

    echo ""

    if [ "$length" -gt 50 ]
    then
	echo "Queue is too long ($length)"
	docker-compose scale analyzer=10
    else 
	echo "Queue is an acceptable length ($length)"
    fi
    docker-compose ps
    echo "======================================================================================="
    echo ""
    sleep $CONTAINER_SCALE_DELAY
done

echo "Lets scale the number of VMs"
echo "Need to increase producers so that we consume all CPU"
read -p "Press [Enter] key to create more producers"
clear 

docker-compose scale producer=$MAX_PRODUCERS

echo "Lets monitor the state of the queue"
echo "Need to increase producers so that we consume all CPU"
read -p "Press [Enter] key to create more producers"
clear 


echo "Scale up the VMS"
read -p "Press [Enter] key to scale the number of VMs up"
clear 

CPU=$(docker info | grep -e "^CPUs:")

echo "Current cluster size: " $CPU

azure group deployment create -n "Auto Scale Rules" -g rgacsswarmdemo -f autoscale.json -e autoscale.params.json

read -p "Press [Enter] key to shut things down"
clear 

docker-compose stop
