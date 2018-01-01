#!/bin/bash
echo "Setting up a docker network"

docker network create cherry

echo "Setting up OrientDB"

docker run --network=cherry --network-alias=orientdb -d -p 2424:2424 -p 2480:2480 -e ORIENTDB_ROOT_PASSWORD=rootpwd --name orientdb orientdb:2.2.28-spatial
ODB_CONTAINER_ID=$(docker ps -q --filter name=orientdb)
echo "Waiting for OrientDB to get started"
sleep 5
echo "OrientDB is up - executing command"
docker exec $ODB_CONTAINER_ID /bin/ash -c "echo CREATE DATABASE remote:localhost/cherry root rootpwd plocal >> /orientdb/startup"
docker exec $ODB_CONTAINER_ID /bin/ash -c "echo CREATE USER cherry IDENTIFIED BY cherry ROLE admin >> /orientdb/startup"
docker exec $ODB_CONTAINER_ID /orientdb/bin/console.sh /orientdb/startup

echo "Starting API"

docker run --network=cherry --network-alias=cherryapi -dp 8082:8082 --name cherryapi --env-file api.env 094416929116.dkr.ecr.us-east-1.amazonaws.com/cherry-be:1.0.0-beta.52
API_CONTAINER_ID=$(docker ps -q --filter name=cherryapi)

until curl -s -o /dev/null -w "%{http_code}" http://localhost:8082/api/v1/auth/ping -gt 0; do
  echo "Waiting for API"
  sleep 3
done

echo "Starting Testing Container"

docker build -t cherry-test .
docker run --name cherrytest --network=cherry cherry-test
TEST_CONTAINER_ID=$(docker ps -aq --filter name=cherrytest)
rm -rf result
docker cp $TEST_CONTAINER_ID:/home/cherry/testfolder ./result

echo "Tearing down"

echo "Teardown Testing Container"

docker rm $TEST_CONTAINER_ID

echo "Tearing down API"

docker rm --force $API_CONTAINER_ID

echo "Tearing down OrientDB"

docker rm --force $ODB_CONTAINER_ID

echo "Tearing down network"

docker network rm cherry
