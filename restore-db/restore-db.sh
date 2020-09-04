#!/usr/bin/env bash
docstring='
We have backup .gz file created at :postgres-start/backup-db/gz_vault/*.gz aka :gz file
We will now restore :gz into a postgres db

*sample usage*
gz=./backup-db/gz_vault/mydb.20200904_153223.gz  ./restore-db/restore-db.sh
'

         SH=`cd $(dirname $BASH_SOURCE) && pwd`
BACKUP_HOME=`cd "$SH/../backup-db"      && pwd`

if [ -z $gz   ]; then echo 'Envvar :gz is required'; exit 1; fi
    if [ ! -f $gz ]; then echo "File not found :gz as $gz"; exit 1; fi
        sql="$gz.sql" ; gunzip -k < $gz > $sql

        echo

        echo "Preparing db container..."
        source "$BACKUP_HOME/.env"
            remote_pgdump_version=`$BACKUP_HOME/00a.get_remote_pgdump_version.sh`
                s=`DOCKER_IMAGE="postgres:$remote_pgdump_version"  "$BACKUP_HOME/00b.prepare-infra.sh" 2>&1`
                    container_name=`echo "$s" | tail -n1`
                    echo $container_name
        echo "Preparing db container... DONE"

        echo

        echo "Restoring... "
            docker exec    $container_name  psql -Upostgres  -c "create database \"$DB_NAME\" "
            docker exec -i $container_name  psql -Upostgres  $DB_NAME < $sql
            #           .  .                .                .          .
        echo "Restoring... DONE"

        echo

        echo "Aftermath table view"
        docker exec $container_name  psql postgresql://postgres:postgres@/$DB_NAME -c '\dt'

        echo

        echo "Command hint"
        echo docker exec $container_name  psql postgresql://postgres:postgres@/$DB_NAME -c '\dt'
