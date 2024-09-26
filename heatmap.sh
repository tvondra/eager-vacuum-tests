#!/usr/bin/bash

./generate-plot.sh heatmap-not-visible-not-frozen-pct "not visible, not frozen (fraction)" blue "select ts, page_perc, (count_not_visible_not_frozen * 1.0 / total) from visibility_age_agg"

./generate-plot.sh heatmap-visible-not-frozen-pct "visible, not frozen (fraction)" red "select ts, page_perc, (count_visible_not_frozen * 1.0 / total) from visibility_age_agg"

./generate-plot.sh heatmap-not-frozen-pct "not frozen (fraction)" green "select ts, page_perc, ((count_not_visible_not_frozen + count_visible_not_frozen) * 1.0 / total) from visibility_age_agg"


./generate-plot.sh heatmap-not-visible-not-frozen-age "not visible, not frozen (age)" blue "with max_ages as (select ts, max(avg_not_visible_not_frozen) as max_age from visibility_age_agg group by ts) select ts, page_perc, coalesce((avg_not_visible_not_frozen * 1.0 / (select max_age from max_ages where max_ages.ts = v.ts)), 0) from visibility_age_agg v"

./generate-plot.sh heatmap-visible-not-frozen-age "visible, not frozen (age)" red "with max_ages as (select ts, max(avg_visible_not_frozen) as max_age from visibility_age_agg group by ts) select ts, page_perc, coalesce((avg_visible_not_frozen * 1.0 / (select max_age from max_ages where max_ages.ts = v.ts)), 0) from visibility_age_agg v"

./generate-plot.sh heatmap-not-frozen-age "not frozen (age)" green "with max_ages as (select ts, max((avg_not_visible_not_frozen * count_not_visible_not_frozen + avg_visible_not_frozen * count_visible_not_frozen) / (count_not_visible_not_frozen + count_visible_not_frozen)) as max_age from visibility_age_agg group by ts) select ts, page_perc, coalesce((((avg_not_visible_not_frozen * count_not_visible_not_frozen + avg_visible_not_frozen * count_visible_not_frozen) / (count_not_visible_not_frozen + count_visible_not_frozen)) * 1.0 / (select max_age from max_ages where max_ages.ts = v.ts)), 0) from visibility_age_agg v"


./generate-chart.sh debt-not-visible-not-frozen-pct "not visible, not frozen (debt)" blue "select ts - (select min(ts) from visibility_percentiles) as ts, avg_age, perc_10, perc_25, perc_50, perc_75, perc_90 from visibility_percentiles where not all_visible and not all_frozen order by ts" "not all_visible and not all_frozen order"

./generate-chart.sh debt-visible-not-frozen-pct "visible, not frozen (debt)" red "select ts - (select min(ts) from visibility_percentiles) as ts, avg_age, perc_10, perc_25, perc_50, perc_75, perc_90 from visibility_percentiles where all_visible and not all_frozen order by ts" "all_visible and not all_frozen"


./generate-debt.sh debt-summary "debt summary" "select ts, total, not_visible_not_frozen, visible_not_frozen, visible_frozen from visibility_summary_agg order by ts"
