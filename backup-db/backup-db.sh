#!/usr/bin/env bash
SH=`cd $(dirname $BASH_SOURCE) && pwd`

source "$SH/.env"
    # prepare pg container that has pg_dump version matched with the one on :DB_HOST
    remote_pgdump_version=`$SH/00a.get_remote_pgdump_version.sh`
    echo "Detected remote_pgdump_version=$remote_pgdump_version"

    echo

    echo "Creating pg_dump container..."
        s=`DOCKER_IMAGE="postgres:$remote_pgdump_version"       "$SH/00b.prepare-infra.sh" 2>&1`
        # postgres docker image with tag as matched version  .                          mute output
            container_name=`echo "$s" | tail -n1`
            echo $container_name
    echo "Creating pg_dump container... DONE"

    echo

    # do backup
    if [ -z $BACKUP_GZ ]; then BACKUP_GZ="$SH/gz_vault/$DB_NAME.`date +%Y%m%d_%H%M%S`.gz"; fi
    docker exec $container_name  pg_dump "postgresql://$DB_USER:$DB_PASS@$DB_HOST:$DB_PORT/$DB_NAME" --no-acl --no-owner | gzip > $BACKUP_GZ  #NOTE must have --no-acl --no-owner
    #            .                .       .             .        .        .         .       .         .                     .
        ls -lah $BACKUP_GZ
