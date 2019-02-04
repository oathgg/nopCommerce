DELETE FROM [NOPCOMMERCE_BLANK]..[Category];
SET IDENTITY_INSERT [NOPCOMMERCE_BLANK]..[Category] ON;

with CTE_Category AS
(
	select distinct
		REPLACE(REPLACE(department.ObjId, 'D', ''), '-', '')	as [Id],
		dlang.Name												as [Name],
		concat(dlang.Intro, dlang.Description)					as [Description],
		1														as [CategoryTemplateId],
		LEFT(dlang.SearchEngKeywords, 400)						as [MetaKeywords],
		dlang.SearchEngDescription								as [MetaDescription],
		dlang.Name												as [MetaTitle],
		CASE
			-- Keep the default ParentID
			WHEN department2.ParentID != '' THEN REPLACE(REPLACE(department.ParentID, 'D', ''), '-', '')
			-- This will become the Main category	
			ELSE 0																
		END														as [ParentCategoryId],
		0														as [PictureId],
		6														as [PageSize],
		1														as [AllowCustomersToSelectPageSize],
		null													as [PageSizeOptions],
		null													as [PriceRanges],
		0														as [ShowOnHomePage],
		0														as [IncludeInTopMenu],
		0														as [SubjectToAcl],
		0														as [LimitedToStores],
		CASE
			-- Keep the default ParentID
			WHEN department2.ParentID != '' THEN department.Visible
			-- This will become the Main category	
			ELSE department2.Visible
		END														as [Published],
		0														as [Deleted],
		ROW_NUMBER() over (partition by department.ParentID order by department.ObjId)				
																as [DisplayOrder],
		GETDATE()												as [CreatedOnUtc],	
		GETDATE()												as [UpdatedOnUtc],
		DupCount = row_number() over (PARTITION BY REPLACE(REPLACE(department.ObjId, 'D', ''), '-', '') ORDER BY REPLACE(REPLACE(department.ObjId, 'D', ''), '-', ''))
	from [SF]..departmentBase department
		JOIN [SF]..departmentLang dlang on dlang.ObjID = department.ObjID
		JOIN [SF]..departmentBase department2 on department2.ObjID = department.ParentID
	where	dlang.Name != ''
	and		dlang.LangName = 'nl'
	and		department.ParentID != ''
	-- Default pages by SF
	and		department.Creation != 0
) 
INSERT INTO [NOPCOMMERCE_BLANK]..[Category]
	([Id], [Name], [Description], [CategoryTemplateId], [MetaKeywords], [MetaDescription], [MetaTitle], [ParentCategoryId], [PictureId], [PageSize], [AllowCustomersToSelectPageSize], [PageSizeOptions], [PriceRanges], [ShowOnHomePage], [IncludeInTopMenu], [SubjectToAcl], [LimitedToStores], [Published], [Deleted], [DisplayOrder], [CreatedOnUtc], [UpdatedOnUtc])
SELECT 
	[Id], [Name], [Description], [CategoryTemplateId], [MetaKeywords], [MetaDescription], [MetaTitle], [ParentCategoryId], [PictureId], [PageSize], [AllowCustomersToSelectPageSize], [PageSizeOptions], [PriceRanges], [ShowOnHomePage], [IncludeInTopMenu], [SubjectToAcl], [LimitedToStores], [Published], [Deleted], [DisplayOrder], [CreatedOnUtc], [UpdatedOnUtc]
FROM [CTE_Category]
	Where DupCount = 1;

SET IDENTITY_INSERT [NOPCOMMERCE_BLANK]..[Category] OFF;
