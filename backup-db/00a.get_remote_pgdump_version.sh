#!/usr/bin/env bash
SH=`cd $(dirname $BASH_SOURCE) && pwd`
source "$SH/.env"
    psql "postgresql://$DB_USER:$DB_PASS@$DB_HOST:$DB_PORT" -c 'select version()' -tA | tail -n1 | cut -d' ' -f2
    # NOTE: pg_dump version is also postgres version so printing the remote version will be suffice to get remote pg_dump version
