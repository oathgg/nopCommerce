DELETE FROM [NOPCOMMERCE_BLANK]..[URLRecord] where EntityName = 'Manufacturer';
DELETE FROM [NOPCOMMERCE_BLANK]..[Manufacturer];

SET IDENTITY_INSERT [NOPCOMMERCE_BLANK]..[Manufacturer] ON;

WITH CTE_Manufacturer AS
(
	SELECT
		-- SF
		REPLACE(ObjId, 'BR', '') AS [Id], 
		Manufacturer	AS [Name],
		Enabled			AS [Published],

		-- DEFAULT
		''				AS [Description],
		1				AS [ManufacturerTemplateId],
		0				AS [PictureId],
		6				AS [PageSize],
		1				AS [AllowCustomersToSelectPageSize],
		0				AS [SubjectToAcl],
		0				AS [LimitedToStores],
		0				AS [Deleted],
		ROW_NUMBER() OVER (PARTITION BY Manufacturer ORDER BY Manufacturer)
						AS [DisplayOrder],
		GETDATE()		AS [CreatedOnUtc],
		GETDATE()		AS [UpdatedOnUtc]
	FROM [SF]..[brandbase]
	WHERE Manufacturer != ''
) 
INSERT INTO [NOPCOMMERCE_BLANK]..[Manufacturer]
(Id, Name, Published, Description, ManufacturerTemplateId, PictureId, PageSize, AllowCustomersToSelectPageSize, SubjectToAcl, LimitedToStores, Deleted, DisplayOrder, CreatedOnUtc, UpdatedOnUtc)
SELECT * FROM [CTE_Manufacturer];

SET IDENTITY_INSERT [NOPCOMMERCE_BLANK]..[Manufacturer] OFF;

insert into [NOPCOMMERCE_BLANK]..[URLRecord]
(EntityId, EntityName, Slug, IsActive, LanguageId)
select 
	[Manufacturer].Id, 'Manufacturer', 
	-- Replaces any weird characters in the slug as this will be used for the URL.
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RTRIM([Manufacturer].NAME)
		, ' ', '-')
		, '/', '')
		, '=', '-')
		, ',', '')
		, '+', '')
		, '(', '')
		, ')', '')
		, '''', '')
		, '--', '-')
	, 1, 0
from [NOPCOMMERCE_BLANK]..[Manufacturer]
	LEFT JOIN [NOPCOMMERCE_BLANK]..[URLRecord] on [URLRecord].EntityId = [Manufacturer].Id
		AND [URLRecord].EntityName = 'Manufacturer'
where	[URLRecord].EntityId IS NULL
AND		[Manufacturer].Published = 1;