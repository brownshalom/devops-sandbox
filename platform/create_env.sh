#!/bin/bash

NAME=$1
TTL=${2:-1800}

ENV_ID="env-$(openssl rand -hex 3)"

NETWORK_NAME="${ENV_ID}-net"

CONTAINER_NAME="${ENV_ID}-app"

mkdir -p logs/$ENV_ID

docker network create $NETWORK_NAME

docker run -d \
--name $CONTAINER_NAME \
--network $NETWORK_NAME \
--label sandbox.env=$ENV_ID \
sandbox-app

CONTAINER_IP=$(docker inspect -f \
'{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
$CONTAINER_NAME)

cat > nginx/conf.d/$ENV_ID.conf <<EOF
server {
    listen 80;

    location /$ENV_ID/ {
        proxy_pass http://$CONTAINER_IP:5000/;
    }
}
EOF

docker exec sandbox-nginx nginx -s reload

CREATED=$(date +%s)

TMP_FILE=$(mktemp)

cat > $TMP_FILE <<EOF
{
  "id": "$ENV_ID",
  "name": "$NAME",
  "created_at": $CREATED,
  "ttl": $TTL,
  "status": "active"
}
EOF

mv $TMP_FILE envs/$ENV_ID.json

docker logs -f $CONTAINER_NAME >> logs/$ENV_ID/app.log 2>&1 &

LOG_PID=$!

echo $LOG_PID > logs/$ENV_ID/logger.pid

echo "Environment Created"
echo "URL: http://localhost/$ENV_ID/"
echo "TTL: $TTL seconds"
