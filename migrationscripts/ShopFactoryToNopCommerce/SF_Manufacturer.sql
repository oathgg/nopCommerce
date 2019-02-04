USE SF;

WITH SF_Manufacturer AS
(
	SELECT
		-- SF
		REPLACE(ObjId, 'BR', '') AS [ManufacturerId], 
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
		ROW_NUMBER() OVER (PARTITION BY [NAME] ORDER BY [NAME])
						AS [DisplayOrder],
		GETDATE()		AS [CreatedOnUtc],
		GETDATE()		AS [UpdatedOnUtc]
	FROM brandbase
) SELECT * FROM SF_Manufacturer