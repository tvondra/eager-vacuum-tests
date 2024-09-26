create table lsn_mapping (
  ts timestamptz,
  epoch float8,
  lsn pg_lsn,
  pos bigint);

create table visibility_summary (
  ts float8,
  all_visible bool,
  all_frozen bool,
  cnt int);

create table visibility (
  ts float8,
  page bigint,
  lsn pg_lsn,
  checksum int,
  flags int,
  lower int,
  upper int,
  special int,
  pagesize int,
  version int,
  prune_xid bigint,
  all_visible bool,
  all_frozen bool,
  pd_frozen bool);

create index on lsn_mapping(ts);
create index on lsn_mapping(lsn);

create or replace function lsn_to_timestamp(pg_lsn) returns timestamptz as $$
  select ts from public.lsn_mapping where lsn < $1 order by lsn desc limit 1;
$$ language sql;

create or replace function lsn_to_epoch(pg_lsn) returns float8 as $$
  select epoch from public.lsn_mapping where lsn < $1 order by lsn desc limit 1;
$$ language sql;

create or replace function timestamp_to_lsn(timestamptz) returns pg_lsn as $$
  select lsn from public.lsn_mapping where ts < $1 order by ts desc limit 1;
$$ language sql;

create view visibility_view as
with min_ts as (select min(ts) AS ts from visibility)
select
  (ts - (select ts from min_ts)) AS ts,
  page,
  all_visible,
  all_frozen,
  (ts - lsn_to_epoch(lsn)) as age
from visibility
order by visibility.ts;

create materialized view visibility_percentiles as
select
  ts,
  all_visible,
  all_frozen,
  avg(age) as avg_age,
  percentile_cont(0.1) within group (order by age) as perc_10,
  percentile_cont(0.25) within group (order by age) as perc_25,
  percentile_cont(0.5) within group (order by age) as perc_50,
  percentile_cont(0.75) within group (order by age) as perc_75,
  percentile_cont(0.9) within group (order by age) as perc_90
from (
  select
    ts::int - mod(ts::int,60) AS ts,
    all_visible,
    all_frozen,
    (ts - lsn_to_epoch(lsn)) as age
  from
    visibility
) group by 1, 2, 3 order by 1, 2, 3;

create materialized view visibility_summary_agg as
select
  ((ts - (select min(ts) from visibility_summary)) /60)::int as ts,
  count(*) as total,
  (avg(cnt) filter (where not all_visible and not all_frozen))::int as not_visible_not_frozen,
  (avg(cnt) filter (where all_visible and not all_frozen))::int as visible_not_frozen,
  (avg(cnt) filter (where all_visible and all_frozen))::int as visible_frozen
from visibility_summary
group by 1 order by 1;

create materialized view visibility_age_agg as
with max_pages as (select (ts/60)::int as ts, max(page) as max_page from visibility_view group by 1)
select
  (v.ts/60)::int as ts,
  (100.0 * page / max_page)::int as page_perc,
  count(*) as total,
  count(*) filter (where not all_visible and not all_frozen) as count_not_visible_not_frozen,
  count(*) filter (where all_visible and not all_frozen) as count_visible_not_frozen,
  count(*) filter (where all_visible and all_frozen) as count_visible_frozen,
  avg(age) filter (where not all_visible and not all_frozen) as avg_not_visible_not_frozen,
  avg(age) filter (where all_visible and not all_frozen) as avg_visible_not_frozen,
  avg(age) filter (where all_visible and all_frozen) as avg_visible_frozen
from visibility_view v
left join max_pages mp on (mp.ts = (v.ts/60)::int)
group by 1,2 order by 1,2;
