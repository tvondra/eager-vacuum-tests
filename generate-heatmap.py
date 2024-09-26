#!/usr/bin/env python

import sys
import psycopg2
import os

FNAME=sys.argv[1]
TITLE=sys.argv[2]
COLOR=sys.argv[3]
QUERY=sys.argv[4]


conn = psycopg2.connect('host=localhost dbname=test')

# determine maximum time
cur = conn.cursor()
cur.execute("select max(ts) from visibility_age_agg")
maxtime = cur.fetchone()[0]

plotfile = open('%(fname)s.plot' % {'fname' : FNAME}, 'w')

plotfile.write("set terminal postscript eps size 10,4 enhanced color font 'Helvetica,10'\n")
plotfile.write("set output '%s.eps'\n" % (FNAME,))
plotfile.write("set title '%s'\n" % (FNAME,))

# write ranges
plotfile.write("set xrange [0:%s]\n" % (maxtime,))
plotfile.write("set yrange [0:100]\n")

cur.execute(QUERY)

n=0
for r in cur:

	n = (n + 1)

	x1 = r[0]
	x2 = (x1 + 1)

	y1 = r[1]
	y2 = (y1 + 1)

	val = r[2]

	val = int((1.0 - float(val)) * 255)

	val = '{:02X}'.format(val)

	if COLOR == 'red':
		rgb = "#FF%(val)s%(val)s" % {'val' : val}
	elif COLOR == 'green':
		rgb = "#%(val)sFF%(val)s" % {'val' : val}
	else:
		rgb = "#%(val)s%(val)sFF" % {'val' : val}

	plotfile.write("set object %(n)s rect from %(x1)d,%(y1)d to %(x2)d,%(y2)d fc rgb '%(rgb)s' fs noborder\n" % {'n' : n, 'x1' : x1, 'x2' : x2, 'y1' : y1, 'y2' : y2, 'rgb' : rgb})

plotfile.write("plot 0")
