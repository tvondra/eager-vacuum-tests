#!/usr/bin/bash

CLIENTS=8
JOBS=8
DURATION=$((3600*6))

# prepared mode does not work well for the UPDATE (generic plan has seqscan)
MODE=simple

dropdb --if-exists test
createdb test

psql test < create.sql

psql test -c "create extension pg_visibility"
psql test -c "create extension pageinspect"

rm -f stop

./collect-lsn.sh &
./collect-stats.sh "hottail" &
./collect-visibility.sh "hottail" &
./collect-visibility-summary.sh "hottail" &

pgbench --progress-timestamp -P 5 --random-seed=0 --no-vacuum -M $MODE -c $CLIENTS -j $CLIENTS -T $DURATION -f hottail.sql test > pgbench.log 2>&1

# signal scripts to stop
touch stop

# wait for scripts to stop
wait
