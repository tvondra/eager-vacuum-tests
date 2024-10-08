set terminal postscript eps size 10,4 enhanced color font 'Helvetica,10'
set output 'debt-visible-not-frozen-pct.eps'
set title 'i5 / patched / visible, not frozen (debt)'
set xrange [0:21600]
set yrange [0:20386.583300161365]
plot 'debt-visible-not-frozen-pct.data' using 1:2 with lines title 'average',      'debt-visible-not-frozen-pct.data' using 1:3 with lines title 'perc 10%',      'debt-visible-not-frozen-pct.data' using 1:4 with lines title 'perc 25%',      'debt-visible-not-frozen-pct.data' using 1:5 with lines title 'perc 50%',      'debt-visible-not-frozen-pct.data' using 1:6 with lines title 'perc 75%',      'debt-visible-not-frozen-pct.data' using 1:7 with lines title 'perc 90%'
