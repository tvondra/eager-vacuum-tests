set terminal postscript eps size 10,4 enhanced color font 'Helvetica,10'
set output 'debt-summary-pct.eps'
set title 'i5 / patched / debt summary (pct)'
set xrange [0:360]
set yrange [0:100]
set key box opaque
plot 'debt-summary-pct.data' using 1:($3+$4+$5) with filledcurves x1 title 'not visible / not frozen',      'debt-summary-pct.data' using 1:($4+$5) with filledcurves x1 title 'visible / not_frozen',      'debt-summary-pct.data' using 1:5 with filledcurves x1 title 'visible / frozen'
