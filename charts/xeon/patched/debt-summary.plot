set terminal postscript eps size 10,4 enhanced color font 'Helvetica,10'
set output 'debt-summary.eps'
set title 'xeon / patched / debt summary'
set xrange [0:303]
set yrange [0:45723347]
plot 'debt-summary.data' using 1:3 with lines title 'not visible / not frozen',      'debt-summary.data' using 1:4 with lines title 'visible / not_frozen',      'debt-summary.data' using 1:5 with lines title 'visible / frozen'
