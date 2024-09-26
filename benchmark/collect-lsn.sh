#!/usr/bin/bash

set -e

rm -f lsn-mapping.data

while /bin/true; do

	if [ -f "stop" ]; then
		break
	fi

	psql -t -A test -c "select now(), extract(epoch from now()), pg_current_wal_lsn(), pg_current_wal_lsn() - '0/0'" >> lsn-mapping.data 2>&1

	sleep 1

done

echo "terminating lsn collection"
