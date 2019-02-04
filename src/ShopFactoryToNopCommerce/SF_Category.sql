USE SF;

-- CATEGORY
with SF_Category AS
(
	select distinct
		-- SF
		REPLACE(REPLACE(department.ObjId, 'D', ''), '-', '')
									as [CategoryId],
		dlang.Name					as [CategoryName],
	
		CASE
			WHEN department2.ParentID != '' 
				THEN REPLACE(REPLACE(department.ParentID, 'D', ''), '-', '') -- Keep the default ParentID
			ELSE '' -- This will become the Main category
		END							as [ParentCategoryId],

		CASE
			WHEN department2.ParentID != '' THEN 0
			ELSE 1
		END							as [IncludeInTopMenu],

		CASE
			WHEN department2.ParentID != '' THEN 0
			ELSE 1
		END							as [ShowOnHomePage],

		dlang.Description			as [Description],
		dlang.Name					as [MetaTitle],
		dlang.SearchEngKeywords		as [MetaKeywords],
		dlang.SearchEngDescription	as [MetaDescription],
		department.Visible			as [Published],

		-- DEFAULT
		0							as [PictureId],
		1							as [CategoryTemplateId],
		6							as [PageSize],
		1							as [AllowCustomersToSelectPageSize],
		0							as [SubjectToAcl],
		0							as [LimitedToStores],
		0							as [Deleted],
		ROW_NUMBER() over (partition by department.ParentID order by department.ObjId)				
									as [DisplayOrder],
		GETDATE()					as [CreatedOnUtc],	
		GETDATE()					as [UpdatedOnUtc]
	from departmentBase department
		JOIN departmentLang dlang on dlang.ObjID = department.ObjID
		JOIN departmentBase department2 on department2.ObjID = department.ParentID
	where	dlang.Name != ''
	and		department.ParentID != ''
	and		dlang.LangName = 'nl'
) select * from SF_Category
	order by CategoryId