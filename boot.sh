#!/bin/bash

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -orientDbTagName|--orientDbTagName)
    ORIENT_DB_TAG_NAME="$2"
    shift # past argument
    shift # past value
    ;;
    -apiTagName|--apiTagName)
    API_TAG_NAME="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

echo orientDbTagName  = "${ORIENT_DB_TAG_NAME}"
echo apiTagName = "${API_TAG_NAME}"

echo "Setting up a docker network"
docker network create cherry

networkTearDown()
{
    echo "Tearing down"
    if [ ! -z "$TEST_CONTAINER_ID" ]; then
        echo "Tearing down Testing Container"
        docker rm --force $TEST_CONTAINER_ID
    fi
    if [ ! -z "$API_CONTAINER_ID" ]; then
        echo "Tearing down API Container"
        docker rm --force $API_CONTAINER_ID
    fi
    if [ ! -z "$ODB_CONTAINER_ID" ]; then
        echo "Tearing down OrientDB Container"
        docker rm --force $ODB_CONTAINER_ID
    fi
    echo "Tearing down Cherry network"
    docker network rm cherry
}

echo "Setting up OrientDB"
docker run --network=cherry --network-alias=orientdb -d -p 2424:2424 -p 2480:2480 -e ORIENTDB_ROOT_PASSWORD=rootpwd --name orientdb orientdb:$ORIENT_DB_TAG_NAME
ODB_CONTAINER_ID=$(docker ps -q --filter name=orientdb)

if [ -z "$ODB_CONTAINER_ID" ]; then
   echo "[Error] While starting OrientDB container."
   networkTearDown
   exit 1
fi

echo "Waiting for OrientDB to get started"
until curl -s -o /dev/null -w "%{http_code}" http://localhost:2480/listDatabases -gt 0; do
  echo "Waiting for OrientDB"
  sleep 3
done
echo "OrientDB is up - executing command"
docker exec $ODB_CONTAINER_ID /bin/ash -c "echo CREATE DATABASE remote:localhost/cherry root rootpwd plocal >> /orientdb/startup"
docker exec $ODB_CONTAINER_ID /bin/ash -c "echo CREATE USER cherry IDENTIFIED BY cherry ROLE admin >> /orientdb/startup"
docker exec $ODB_CONTAINER_ID /orientdb/bin/console.sh /orientdb/startup

echo "Starting API"

docker run --network=cherry --network-alias=cherryapi -dp 8082:8082 --name cherryapi --env-file api.env 094416929116.dkr.ecr.us-east-1.amazonaws.com/cherry-be:$API_TAG_NAME
API_CONTAINER_ID=$(docker ps -q --filter name=cherryapi)

if [ -z "$API_CONTAINER_ID" ]; then
   echo "[Error] While starting API container."
   networkTearDown
   exit 1
fi

until curl -s -o /dev/null -w "%{http_code}" http://localhost:8082/api/v1/auth/ping -gt 0; do
  echo "Waiting for API"
  sleep 3
done

echo "Starting Testing Container"
docker build -t cherry-test .
docker run --name cherrytest --network=cherry cherry-test
TEST_CONTAINER_ID=$(docker ps -aq --filter name=cherrytest)

while read -r line_of_output; do
  SUCCESSFUL_EXECUTION=$line_of_output
done < <(docker cp $TEST_CONTAINER_ID:/cherryTests/testreport.jtl ./testreport.jtl 2>&1)
if [ ! -z "$SUCCESSFUL_EXECUTION" ]
    then
        echo "Error occurred while test execution.";
        networkTearDown
        exit 1;
fi

TEST_RESULT=$( awk -F "\"*,\"*" '{print $8}' testreport.jtl | grep false )
if [ ! -z "$TEST_RESULT" ]
    then
        echo "Test failed";
        networkTearDown
        exit 1;
    else
        echo "Test passed";
fi

networkTearDown