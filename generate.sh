#!/usr/bin/bash

set -e

rm -f *.eps *.plot *.data

for m in xeon i5; do

	for b in master patched; do

		dropdb --if-exists test
		createdb test

		psql test < create.sql

		cat $m/$b/lsn-mapping.data | psql test -c "copy lsn_mapping from stdin with (format csv, delimiter '|')"
		cat $m/$b/visibility-summary.data | psql test -c "copy visibility_summary from stdin with (format csv, delimiter '|')"

		for f in $m/$b/visibility.data.*; do
			gunzip -c $f | psql test -c "copy visibility from stdin with (format csv, delimiter '|')"
		done

		psql test <<EOF
refresh materialized view visibility_percentiles;
refresh materialized view visibility_summary_agg;
refresh materialized view visibility_age_agg;
EOF

		echo "heatmap-not-visible-not-frozen-pct"
		./generate-heatmap.py heatmap-not-visible-not-frozen-pct "$m / $b / not visible, not frozen (fraction)" blue "select ts, page_perc, (count_not_visible_not_frozen * 1.0 / total) from visibility_age_agg"

		echo "heatmap-visible-not-frozen-pct"
		./generate-heatmap.py heatmap-visible-not-frozen-pct "$m / $b / visible, not frozen (fraction)" red "select ts, page_perc, (count_visible_not_frozen * 1.0 / total) from visibility_age_agg"

		echo "heatmap-not-frozen-pct"
		./generate-heatmap.py heatmap-not-frozen-pct "$m / $b / not frozen (fraction)" green "select ts, page_perc, ((count_not_visible_not_frozen + count_visible_not_frozen) * 1.0 / total) from visibility_age_agg"


		echo "heatmap-not-visible-not-frozen-age"
		./generate-heatmap.py heatmap-not-visible-not-frozen-age "$m / $b / not visible, not frozen (age)" blue "with max_ages as (select ts, max(avg_not_visible_not_frozen) as max_age from visibility_age_agg group by ts) select ts, page_perc, coalesce((avg_not_visible_not_frozen * 1.0 / (select max_age from max_ages where max_ages.ts = v.ts)), 0) from visibility_age_agg v"

		echo "heatmap-visible-not-frozen-age"
		./generate-heatmap.py heatmap-visible-not-frozen-age "$m / $b / visible, not frozen (age)" red "with max_ages as (select ts, max(avg_visible_not_frozen) as max_age from visibility_age_agg group by ts) select ts, page_perc, coalesce((avg_visible_not_frozen * 1.0 / (select max_age from max_ages where max_ages.ts = v.ts)), 0) from visibility_age_agg v"

		echo "heatmap-not-frozen-age"
		./generate-heatmap.py heatmap-not-frozen-age "$m / $b / not frozen (age)" green "with max_ages as (select ts, max((avg_not_visible_not_frozen * count_not_visible_not_frozen + avg_visible_not_frozen * count_visible_not_frozen) / (count_not_visible_not_frozen + count_visible_not_frozen)) as max_age from visibility_age_agg group by ts) select ts, page_perc, coalesce((((avg_not_visible_not_frozen * count_not_visible_not_frozen + avg_visible_not_frozen * count_visible_not_frozen) / (count_not_visible_not_frozen + count_visible_not_frozen)) * 1.0 / (select max_age from max_ages where max_ages.ts = v.ts)), 0) from visibility_age_agg v"


		echo "debt-not-visible-not-frozen-pct"
		./generate-chart.sh debt-not-visible-not-frozen-pct "$m / $b / not visible, not frozen (debt)" blue "select ts - (select min(ts) from visibility_percentiles) as ts, avg_age, perc_10, perc_25, perc_50, perc_75, perc_90 from visibility_percentiles where not all_visible and not all_frozen order by 1" "not all_visible and not all_frozen"

		echo "debt-visible-not-frozen-pct"
		./generate-chart.sh debt-visible-not-frozen-pct "$m / $b / visible, not frozen (debt)" red "select ts - (select min(ts) from visibility_percentiles) as ts, avg_age, perc_10, perc_25, perc_50, perc_75, perc_90 from visibility_percentiles where all_visible and not all_frozen order by 1" "all_visible and not all_frozen"


		echo "debt-summary"
		./generate-debt.sh debt-summary "$m / $b / debt summary" "select ts, total, not_visible_not_frozen, visible_not_frozen, visible_frozen from visibility_summary_agg order by ts"

		echo "debt-summary-pct"
		./generate-debt-pct.sh debt-summary-pct "$m / $b / debt summary (pct)" "select ts, (not_visible_not_frozen + visible_not_frozen + visible_frozen), 100.0 * not_visible_not_frozen / (not_visible_not_frozen + visible_not_frozen + visible_frozen), 100.0 * visible_not_frozen / (not_visible_not_frozen + visible_not_frozen + visible_frozen), 100.0 * visible_frozen / (not_visible_not_frozen + visible_not_frozen + visible_frozen) from visibility_summary_agg order by ts"

		echo "generating eps"
		for f in *.plot; do
			gnuplot $f
			magick convert -density 200 ${f/plot/eps} ${f/plot/png};
		done

		rm -Rf charts/$m/$b
		mkdir -p charts/$m/$b

		mv *.data *.plot *.eps *.png charts/$m/$b

	done

done
