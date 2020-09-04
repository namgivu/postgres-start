#!/usr/bin/env bash
SH=`cd $(dirname $BASH_SOURCE) && pwd`

docstring='
we will backup using pg_dump and that requires having the version matched with the one on DB_HOST
--> we need to wire up a postgres container that have postgres version matched with the postgres instance on DB_HOST

quoted error when version not matched
> pg_dump: server version: 11.5 (Debian 11.5-3.pgdg90+1); pg_dump version: 10.14 (Ubuntu 10.14-0ubuntu0.18.04.1)
> pg_dump: aborting because of server version mismatch

*sample usage*
                              00.prepare-infra.sh
DOCKER_IMAGE=postgres:latest  00.prepare-infra.sh
'

CONTAINER_NAME='pgdump_c200904'  # pgdump_c200904 aka pg_dump container made on 2020-09-04
if [ -z $DOCKER_IMAGE ]; then DOCKER_IMAGE='postgres:latest'; fi  # pg version will pass in as docker image tag here

    docker stop -t1 $CONTAINER_NAME ; docker rm -f $CONTAINER_NAME

    # ref. https://hub.docker.com/_/postgres?tab=description
    docker run -d             --name $CONTAINER_NAME  -e POSTGRES_PASSWORD=postgres  $DOCKER_IMAGE
    #          detached mode  .                       set password                   .

    sleep 1 ; echo
    docker ps                                             | grep -iE "IMAGE|NAMES|PORTS|$CONTAINER_NAME" --color=always
    docker ps --format '{{.Names}} {{.Ports}} {{.Image}}' | grep -iE $CONTAINER_NAME --color=always

    # print pg_dump version
    docker exec $CONTAINER_NAME sh -c 'pg_dump --version ; psql --version ; psql -Upostgres -c "select version()" -tA' | grep -E 'pg_dump|psql|PostgreSQL| [0-9]+' --color=always
        sample_version='
        pg_dump (PostgreSQL) 12.2 (Debian 12.2-2.pgdg100+1)
        psql (PostgreSQL) 12.2 (Debian 12.2-2.pgdg100+1)
        PostgreSQL 12.2 (Debian 12.2-2.pgdg100+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 8.3.0-6) 8.3.0, 64-bit
        '
