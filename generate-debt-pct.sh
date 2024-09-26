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
ymax=100

echo "set xrange [0:$xmax]" >> $FNAME.plot
echo "set yrange [0:$ymax]" >> $FNAME.plot

psql -F ' ' -t -A test -c "$QUERY" > $FNAME.data

echo 'set key box opaque' >> $FNAME.plot

echo "plot '$FNAME.data' using 1:(\$3+\$4+\$5) with filledcurves x1 title 'not visible / not frozen', \
     '$FNAME.data' using 1:(\$4+\$5) with filledcurves x1 title 'visible / not_frozen', \
     '$FNAME.data' using 1:5 with filledcurves x1 title 'visible / frozen'" >> $FNAME.plot

