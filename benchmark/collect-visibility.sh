#!/usr/bin/bash

TABLE=$1

set -e

rm -f visibility.data

# how many pages to sample per second (at most)
MAX_READS=$((16*128))	# 16 MB/s

while /bin/true; do

	if [ -f "stop" ]; then
		break
	fi

	# how large is the table right now
	relpages=$(psql -t -A test -c "select pg_relation_size('$TABLE')/8192")

	# time per page, to keep the maximum throughput
	page_time=$(psql -t -A test -c "select greatest((1.0 / GREATEST(1, $relpages)), 1.0 / $MAX_READS)")

	# randomize the order of pages
	echo $(date +%s) "pages; $relpages  page_time: $page_time"

        n=0
	s=$(psql -t -A test -c "select extract(epoch from now())")
	e=$(psql -t -A test -c "select $s + 1.0")

	psql -t -A test -c "with pages as (select p from generate_series(0, ($relpages - 1)) s(p) order by random() limit $MAX_READS) select extract(epoch from now()), p, h.*, v.* from pages, lateral page_header(get_raw_page('$TABLE', p)) h, lateral pg_visibility('$TABLE', p) v" >> visibility.data 2>&1

	d=$(psql -t -A test -c "select $e - extract(epoch from now())")
	w=$(psql -t -A test -c "select $e > extract(epoch from now())")

	if [ "$w" == "t" ]; then
		psql -t -A test -c "select pg_sleep($d)"
	fi

done

echo "terminating visibility collection"
