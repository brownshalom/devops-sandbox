#!/bin/bash

while true
do
    for file in envs/*.json
    do
        [ -e "$file" ] || continue

        ENV_ID=$(jq -r '.id' $file)
        CREATED=$(jq -r '.created_at' $file)
        TTL=$(jq -r '.ttl' $file)

        NOW=$(date +%s)

        EXPIRE=$((CREATED + TTL))

        if [ $NOW -gt $EXPIRE ]; then
            echo "$(date) destroying $ENV_ID" >> logs/cleanup.log

            ./platform/destroy_env.sh $ENV_ID
        fi
    done

    sleep 60
done
