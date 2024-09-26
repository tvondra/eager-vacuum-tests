#!/usr/bin/bash

set -e

FNAME=$1
TITLE=$2
QUERY=$3

echo "set terminal postscript eps size 10,4 enhanced color font 'Helvetica,10'" > $FNAME.plot
echo "set output '$FNAME.eps'" >> $FNAME.plot

echo "set title '$TITLE'" >> $FNAME.plot

# determine maximum time
xmax=$(psql -t -A test -c "select max(ts) - min(ts) from visibility_summary_agg")
ymax=$(psql -t -A test -c "select max(not_visible_not_frozen + visible_not_frozen + visible_frozen) from visibility_summary_agg")

echo "set xrange [0:$xmax]" >> $FNAME.plot
echo "set yrange [0:$ymax]" >> $FNAME.plot

psql -F ' ' -t -A test -c "$QUERY" > $FNAME.data

echo "plot '$FNAME.data' using 1:3 with lines title 'not visible / not frozen', \
     '$FNAME.data' using 1:4 with lines title 'visible / not_frozen', \
     '$FNAME.data' using 1:5 with lines title 'visible / frozen'" >> $FNAME.plot

gnuplot $FNAME.plot
