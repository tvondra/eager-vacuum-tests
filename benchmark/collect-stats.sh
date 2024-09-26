#!/usr/bin/bash

TABLE=$1

set -e

rm -f table-stats.data database-stats.data

psql -A test -c "select now(), extract(epoch from now()) as ts, d.* from pg_stat_database d" | head -n 1 > database-stats.data
psql -A test -c "select now(), extract(epoch from now()) as ts, c.*, t.*, (pg_relation_size('$TABLE')/8192) as real_pages from pg_class c join pg_stat_user_tables t on (c.oid = t.relid) where c.relname IN ('$TABLE')" | head -n 1 > table-stats.data

while /bin/true; do

	if [ -f "stop" ]; then
		break
	fi

	psql -A test -c "select now(), extract(epoch from now()) as ts, d.* from pg_stat_database d" >> database-stats.data
	psql -t -A test -c "select now(), extract(epoch from now()), c.*, t.*, (pg_relation_size('$TABLE')/8192) as real_pages from pg_class c join pg_stat_user_tables t on (c.oid = t.relid) where c.relname IN ('$TABLE')" >> table-stats.data

	sleep 1

done

echo "terminating stats collection"
