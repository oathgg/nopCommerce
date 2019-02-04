DELETE FROM [NOPCOMMERCE_BLANK]..[Manufacturer];
SET IDENTITY_INSERT [NOPCOMMERCE_BLANK]..[Manufacturer] ON;

WITH CTE_Manufacturer AS
(
	SELECT
		REPLACE(ObjId, 'BR', '') AS [Id], 
		Manufacturer	AS [Name],
		Enabled			AS [Published],
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