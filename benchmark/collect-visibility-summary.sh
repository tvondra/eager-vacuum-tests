#!/usr/bin/bash

TABLE=$1

set -e

rm -f visibility-summary.data

# how many pages to sample per second (at most)
next=$(date +%s)

while /bin/true; do

	if [ -f "stop" ]; then
		break
	fi

	next=$((next + 15))

	psql -t -A test -c "select extract(epoch from now()), all_visible, all_frozen, count(*) from pg_visibility_map('$TABLE') group by 1, 2, 3" >> visibility-summary.data 2>&1

	d=$(date +%s)

	sleep $((next - d))

done

echo "terminating visibility summary collection"
