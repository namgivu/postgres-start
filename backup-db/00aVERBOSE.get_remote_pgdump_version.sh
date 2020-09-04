#!/usr/bin/env bash
SH=`cd $(dirname $BASH_SOURCE) && pwd`
    source "$SH/.env"
        NOTE='we try a dump - expect to see remote version printed when mismatched'
        s=`pg_dump "postgresql://$DB_USER:$DB_PASS@$DB_HOST:$DB_PORT" --schema-only                                   2>&1`
        #                                                             schema so that dump in minimum if can get thru  stderr into stdout
            if [[ $s == *'pg_dump: aborting because of server version mismatch'* ]]; then is_mismatch=1; else is_mismatch=0; fi
            if [ $is_mismatch == 1 ]; then
                should_have='
                pg_dump: server version: 11.5 (Debian 11.5-3.pgdg90+1); pg_dump version: 10.14 (Ubuntu 10.14-0ubuntu0.18.04.1)
                pg_dump: aborting because of server version mismatch
                '
                echo "$s" | head -n1 | cut -d' ' -f4
            fi

#NOTE can simply just go for this
#psql "postgresql://$DB_USER:$DB_PASS@$DB_HOST:$DB_PORT" -c 'select version()' -tA
