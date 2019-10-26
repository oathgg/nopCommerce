-- MANUFACTURER
DELETE FROM [NOPCOMMERCE_BLANK]..[URLRecord] where EntityName = 'Manufacturer';
insert into [NOPCOMMERCE_BLANK]..[URLRecord]
(EntityId, EntityName, Slug, IsActive, LanguageId)
select 
	[Manufacturer].Id, 'Manufacturer', 
	-- Replaces any weird characters in the slug as this will be used for the URL.
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RTRIM([Manufacturer].NAME)
		, ' ', '-')
		, '/', '')
		, '=', '-')
		, ',', '')
		, '+', '')
		, '(', '')
		, ')', '')
		, '''', '')
		, '&', '')
		, '--', '-')
	, 1, 0
from [NOPCOMMERCE_BLANK]..[Manufacturer]
	LEFT JOIN [NOPCOMMERCE_BLANK]..[URLRecord] on [URLRecord].EntityId = [Manufacturer].Id
		AND [URLRecord].EntityName = 'Manufacturer'
where	[URLRecord].EntityId IS NULL;


-- CATEGORY
DELETE FROM [NOPCOMMERCE_BLANK]..[URLRecord] where EntityName = 'Category';
insert into [NOPCOMMERCE_BLANK]..[URLRecord]
(EntityId, EntityName, Slug, IsActive, LanguageId)
select 
	[Category].Id, 'Category', 
	-- Replaces any weird characters in the slug as this will be used for the URL.
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM([Category].NAME))
		, ' ', '-')
		, '/', '')
		, '=', '-')
		, ',', '')
		, '+', '')
		, '(', '')
		, ')', '')
		, '''', '')
		, '&', '')
		, '--', '-') 
	, 1, 0
from [NOPCOMMERCE_BLANK]..[Category]
	LEFT JOIN [NOPCOMMERCE_BLANK]..[URLRecord] on [URLRecord].EntityId = [Category].Id
		AND [URLRecord].EntityName = 'Category'
where	[URLRecord].EntityId IS NULL;


-- PRODUCT
DELETE FROM [NOPCOMMERCE_BLANK]..[URLRecord] where EntityName = 'Product';
insert into [NOPCOMMERCE_BLANK]..[URLRecord]
	(EntityId, EntityName, Slug, IsActive, LanguageId)
select 
	[Product].Id, 'Product', 
	-- Replaces any weird characters in the slug as this will be used for the URL.
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM([Product].NAME))
		, ' ', '-')
		, '/', '')
		, '=', '-')
		, ',', '')
		, '+', '')
		, '(', '')
		, ')', '')
		, '''', '')
		, '&', '')
		, '--', '-') 
	, 1, 0
from [NOPCOMMERCE_BLANK]..[Product]
	LEFT JOIN [NOPCOMMERCE_BLANK]..[URLRecord] on [URLRecord].EntityId = [Product].Id
		AND [URLRecord].EntityName = 'Product'
where	[URLRecord].EntityId IS NULL;


-- Give duplicates a unique name.
WITH cte AS (
	SELECT *, rn = ROW_NUMBER() OVER (PARTITION BY [Slug] ORDER BY [EntityId])
	FROM [NOPCOMMERCE_BLANK]..[UrlRecord]
) UPDATE cte
	SET [slug] += '-' + CAST(rn as NVARCHAR(MAX))
WHERE rn > 1;