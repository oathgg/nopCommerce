DELETE FROM [NOPCOMMERCE_BLANK]..[URLRecord] where EntityName = 'Category';
DELETE FROM [NOPCOMMERCE_BLANK]..[Category];
SET IDENTITY_INSERT [NOPCOMMERCE_BLANK]..[Category] ON;

with CTE_Category AS
(
	select distinct
		REPLACE(REPLACE(department.ObjId, 'D', ''), '-', '') as [Id],
		dlang.Name					as [Name],
		concat(dlang.Intro, dlang.Description)			
									as [Description],
		1							as [CategoryTemplateId],
		LEFT(dlang.SearchEngKeywords, 400)		as [MetaKeywords],
		dlang.SearchEngDescription	as [MetaDescription],
		dlang.Name					as [MetaTitle],
		CASE
			-- Keep the default ParentID
			WHEN department2.ParentID != '' THEN REPLACE(REPLACE(department.ParentID, 'D', ''), '-', '')
			-- This will become the Main category	
			ELSE 0																
		END							as [ParentCategoryId],
		0							as [PictureId],
		6							as [PageSize],
		1							as [AllowCustomersToSelectPageSize],
		null						as [PageSizeOptions],
		null						as [PriceRanges],
		0							as [ShowOnHomePage],
		0							as [IncludeInTopMenu],
		0							as [SubjectToAcl],
		0							as [LimitedToStores],
		CASE
			-- Keep the default ParentID
			WHEN department2.ParentID != '' THEN department.Visible
			-- This will become the Main category	
			ELSE department2.Visible
		END							as [Published],
		--department.Visible			as [Published],
		0							as [Deleted],
		ROW_NUMBER() over (partition by department.ParentID order by department.ObjId)				
									as [DisplayOrder],
		GETDATE()					as [CreatedOnUtc],	
		GETDATE()					as [UpdatedOnUtc],
		DupCount = row_number() over (PARTITION BY REPLACE(REPLACE(department.ObjId, 'D', ''), '-', '') ORDER BY REPLACE(REPLACE(department.ObjId, 'D', ''), '-', ''))
	from departmentBase department
		JOIN departmentLang dlang on dlang.ObjID = department.ObjID
		JOIN departmentBase department2 on department2.ObjID = department.ParentID
	where	dlang.Name != ''
	and		dlang.LangName = 'nl'
	and		department.ParentID != ''
	-- Default pages by SF
	and		department.Creation != 0
) 
INSERT INTO [NOPCOMMERCE_BLANK]..[Category]
	([Id], [Name], [Description], [CategoryTemplateId], [MetaKeywords], [MetaDescription], [MetaTitle], [ParentCategoryId], [PictureId], [PageSize], [AllowCustomersToSelectPageSize], 
		[PageSizeOptions], [PriceRanges], [ShowOnHomePage], [IncludeInTopMenu], [SubjectToAcl], [LimitedToStores], [Published], [Deleted], [DisplayOrder], [CreatedOnUtc], [UpdatedOnUtc])
SELECT [Id], [Name], [Description], [CategoryTemplateId], [MetaKeywords], [MetaDescription], [MetaTitle], [ParentCategoryId], [PictureId], [PageSize], [AllowCustomersToSelectPageSize], 
		[PageSizeOptions], [PriceRanges], [ShowOnHomePage], [IncludeInTopMenu], [SubjectToAcl], [LimitedToStores], [Published], [Deleted], [DisplayOrder], [CreatedOnUtc], [UpdatedOnUtc]
FROM [CTE_Category]
	-- Ignore duplicates.
	Where DupCount < 2

SET IDENTITY_INSERT [NOPCOMMERCE_BLANK]..[Category] OFF;

-- Adds URL routing to the website
insert into [NOPCOMMERCE_BLANK]..[URLRecord]
(EntityId, EntityName, Slug, IsActive, LanguageId)
select 
	[Category].Id, 'Category', 
	-- Replaces any weird characters in the slug as this will be used for the URL.
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM([Category].NAME))
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
from [NOPCOMMERCE_BLANK]..[Category]
	LEFT JOIN [NOPCOMMERCE_BLANK]..[URLRecord] on [URLRecord].EntityId = [Category].Id
		AND [URLRecord].EntityName = 'Category'
where	[URLRecord].EntityId IS NULL
AND		[Category].Published = 1;