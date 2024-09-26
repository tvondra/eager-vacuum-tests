set terminal postscript eps size 10,4 enhanced color font 'Helvetica,10'
set output 'debt-not-visible-not-frozen-pct.eps'
set title 'xeon / master / not visible, not frozen (debt)'
set xrange [0:21600]
set yrange [0:8749.88146982193]
plot 'debt-not-visible-not-frozen-pct.data' using 1:2 with lines title 'average',      'debt-not-visible-not-frozen-pct.data' using 1:3 with lines title 'perc 10%',      'debt-not-visible-not-frozen-pct.data' using 1:4 with lines title 'perc 25%',      'debt-not-visible-not-frozen-pct.data' using 1:5 with lines title 'perc 50%',      'debt-not-visible-not-frozen-pct.data' using 1:6 with lines title 'perc 75%',      'debt-not-visible-not-frozen-pct.data' using 1:7 with lines title 'perc 90%'
