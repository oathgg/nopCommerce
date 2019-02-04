use sf;

-- MANUFACTURER
select * from brandbase

-- CATEGORY
with SF_Category as
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

-- PRODUCT
select 
	product.ObjID		as [ProductId],
	plang.Name			as [ProductName],
	dlang.Name			as [CategoryName],
	department.ParentId as [CategoryParentId]
from productBase product
	JOIN productLang plang on plang.ObjID = product.ObjID
	JOIN Links plink on plink.strTo = product.ObjID
	JOIN departmentBase department on department.ObjID = plink.strFrom
	JOIN departmentLang dlang on dlang.ObjID = department.ObjID
where dlang.LangName = 'nl'
	and department.ParentID != ''

/*
	ID			PID	PIDREF	strFrom	strTo	strTo2	LinkData
	952781668	SL1	5		D960	P8415		
	952781669	SL1	6		D960	P8416		
	952781670	SL1	7		D960	P8417		
	952781671	SL1	8		D960	P8418		
	952781672	SL1	9		D960	P8419		
	952781673	SL1	10		D960	P8420		
	952781674	SL1	11		D960	P8421		
*/

-- Contains the relations from Product to Category
select * from Links
	where PID = 'SL1'

-- Contains the Category and all sub categories
select dl.Name, * from departmentBase db
	join departmentLang dl on dl.ObjID = db.ObjID
where LangName = 'nl'
	and db.objid = 'D-38'

-- Contains the Product
select pl.name, * from productBase pb
	JOIN productLang pl on pl.ObjID = pb.ObjID
where pb.objid in 
(
	'P8416',
	'P8415',
	'P8417',
	'P8418',
	'P8419',
	'P8420',
	'P8421'
)