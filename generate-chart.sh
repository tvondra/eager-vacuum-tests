#!/usr/bin/bash

set -e

FNAME=$1
TITLE=$2
COLOR=$3
QUERY=$4
WHERE=$5

echo "set terminal postscript eps size 10,4 enhanced color font 'Helvetica,10'" > $FNAME.plot
echo "set output '$FNAME.eps'" >> $FNAME.plot

echo "set title '$TITLE'" >> $FNAME.plot

# determine maximum time
xmax=$(psql -t -A test -c "select max(ts) - min(ts) from visibility_percentiles")
ymax=$(psql -t -A test -c "select max(perc_90) from visibility_percentiles where $WHERE")

echo "set xrange [0:$xmax]" >> $FNAME.plot
echo "set yrange [0:$ymax]" >> $FNAME.plot

psql -F ' ' -t -A test -c "$QUERY" > $FNAME.data

echo "plot '$FNAME.data' using 1:2 with lines title 'average', \
     '$FNAME.data' using 1:3 with lines title 'perc 10%', \
     '$FNAME.data' using 1:4 with lines title 'perc 25%', \
     '$FNAME.data' using 1:5 with lines title 'perc 50%', \
     '$FNAME.data' using 1:6 with lines title 'perc 75%', \
     '$FNAME.data' using 1:7 with lines title 'perc 90%'" >> $FNAME.plot
