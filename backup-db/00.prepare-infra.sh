#!/usr/bin/env bash
SH=`cd $(dirname $BASH_SOURCE) && pwd`

docstring='
we will backup using pg_dump and that requires having the version matched with the one on DB_HOST
--> we need to wire up a postgres container that have postgres version matched with the postgres instance on DB_HOST
'

CONTAINER_NAME='pgdump_c200904'  # pgdump_c200904 aka pg_dump container made on 2020-09-04
    docker stop -t1 $CONTAINER_NAME ; docker rm -f $CONTAINER_NAME

    # ref. https://hub.docker.com/_/postgres?tab=description
    docker run -d             --name $CONTAINER_NAME  -e POSTGRES_PASSWORD=postgres  postgres:latest
    #          detached mode  .                       set password                   docker image

    sleep 1 ; echo
    docker ps                                             | grep -iE "IMAGE|NAMES|PORTS|$CONTAINER_NAME" --color=always
    docker ps --format '{{.Names}} {{.Ports}} {{.Image}}' | grep -iE $CONTAINER_NAME --color=always

    # print pg_dump version
    docker exec $CONTAINER_NAME pg_dump --version | grep -E '[0-9]+' --color=always
