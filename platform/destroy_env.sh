#!/bin/bash

ENV_ID=$1

CONTAINER=$(docker ps -a \
--filter label=sandbox.env=$ENV_ID \
--format "{{.Names}}")

docker stop $CONTAINER
docker rm $CONTAINER

docker network rm ${ENV_ID}-net

rm nginx/conf.d/$ENV_ID.conf

docker exec sandbox-nginx nginx -s reload

mkdir -p logs/archived/$ENV_ID

mv logs/$ENV_ID/* logs/archived/$ENV_ID/ 2>/dev/null

if [ -f logs/archived/$ENV_ID/logger.pid ]; then
    kill $(cat logs/archived/$ENV_ID/logger.pid)
fi

rm -rf logs/$ENV_ID

rm envs/$ENV_ID.json

echo "$ENV_ID destroyed"
