#!/bin/bash

while [[ $# -gt 0 ]]; do
  case $1 in
    --env)
      ENV_ID="$2"
      shift 2
      ;;
    --mode)
      MODE="$2"
      shift 2
      ;;
  esac
done

CONTAINER=$(docker ps \
--filter label=sandbox.env=$ENV_ID \
--format "{{.Names}}")

case $MODE in
  crash)
    docker kill $CONTAINER
    ;;
  pause)
    docker pause $CONTAINER
    ;;
  recover)
    docker unpause $CONTAINER
    docker start $CONTAINER
    ;;
esac
