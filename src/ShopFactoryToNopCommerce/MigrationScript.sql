/*	Automated migration script to migrate all data from ShopFactory to NopCommerce

	- Payments through iDeal ??
	- Categories
		- Main categories
		- Sub categories
	- Products
		- Image
		- Title
		- Short description
		- Full description
		- Price
	- Payment methods
	- Transfer methods
*/

/*	NOPCOMMERCE TABLES
	
	/* 
		BASE TABLES
	*/
	- [Category]
		-- FROM SF
		-> [Name]
		-> [Description]
		-> [MetaKeywords]
		-> [MetaDescription]
		-> [MetaTitle]

		-- DEFAULT
		-> [PictureId] Not null, Generated
		-> [CategoryTemplateId], 1
		-> [ParentCategoryId] Not null, if main category then 0.
		-> [PageSize] Not null, 6
		-> [AllowCustomersToSelectPageSize], 1
		-> [ShowOnHomePage], 0
		-> [IncludeInTopMenu], 0
		-> [SubjectToAcl], 0
		-> [LimitedToStores], 0
		-> [Published], 1
		-> [Deleted], 0
		-> [DisplayOrder], Incremental +1
		-> [CreatedOnUtc], DateTimeNow
		-> [UpdatedOnUtc], DateTimeNow

	- [Product]
		-- FROM SF
		-> [Name]
		-> [ShortDescription]
		-> [FullDescription
		-> [MetaKeywords]
		-> [MetaDescription]
		-> [MetaTitle]
		-> [Sku], Vendor product Id
		-> [Price]
		-> [OldPrice], if available.

		-- DEFAULT
		-> 

	/*	
		INSERT THROUGH POWERSHELL AS THESE FILES ARE LOCATED ON THE DRIVE
		WE WILL ALSO HAVE TO UPDATE THE [PICTUREBINARY] TABLE.
	*/
	- [Picture]
		-- FROM SF
		-> [SeoFilename]
		-> [AltAttribute]
		-> [TitleAttribute]
		-> [MimeType] : 'image/jpeg'

		-- DEFAULT
		-> [Id], Generated
		-> [IsNew], 0

	- [PictureBinary]
		-- FROM PS
		-> [PictureId], -> Take the [Id] from the [Picture] table.
		-> [BinaryData], Convert image to binary file with Powershell.

		-- DEFAULT
		-> [Id], Generated


	/*	
		DEPENDANCY TABLES
	*/
	-> [Product_Category_Mapping]
		- [Product].[Id] -> [Product_Category_Mapping].[ProductId]
		- [Product_Category_Mapping].[CategoryId] -> [Category].[Id]
	-> [Product_Picture_Mapping]
		- [Product].[Id] -> [Product_Picture_Mapping].[ProductId]
		- [Product_Picture_Mapping].[PictureId] -> [Picture].[Id]
	-> [Product_Manufacturer_Mapping]
		- [Product].[Id] -> [Product_Manufacturer_Mapping].[ProductId]
		- [Product_Manufacturer_Mapping].[ManufacturerId] -> [Manufacturer].[Id]
	-> [Product_ProductAttribute_Mapping]
		- [Product].[Id] -> [Product_ProductAttribute_Mapping].[ProductId]
		- [Product_ProductAttribute_Mapping].[ProductAttributeId] -> [ProductAttribute].[Id]
*/


use sf;

-- Manufacturer
select * from brandbase;

-- Product
select * from productBase pb
	JOIN productLang pl on pl.ObjID = pb.ObjID
where pl.LangName = 'nl'

-- Category
select * from departmentBase db
	join departmentLang dl on dl.ObjID = db.ObjID
where ParentID != ''
	and dl.LangName = 'nl'

-- FLAT LINE FOR PRODUCT
select 
	plang.Name as [ProductName], 
	dlang.Name as [CategoryName]
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
	--and db.objid = 'D-33'

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