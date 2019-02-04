USE NOPCOMMERCE_BLANK;

with cte as (
  select *, rn = row_number() over (partition by Slug order by EntityId)
  from UrlRecord
) update cte
	SET slug = slug + '-' + CAST(rn as NVARCHAR(MAX))
where rn > 1;