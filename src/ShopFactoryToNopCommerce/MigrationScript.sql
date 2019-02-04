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

-- MANUFACTURER
select * from brandbase

-- CATEGORY
select distinct
	department.ObjId		as [SF_CategoryId],
	
	-- If the ParentId is empty of the Parent then this will become the main Category
	-- The reason why we do this is because SF has everything under parents which are called 'Index', 'Index 2', 'Index 3'
	CASE
		WHEN department2.ParentID != '' THEN department.ParentID -- Indicates that this is still fine as the root
		ELSE '' -- Reset the ParentId of the Parent, as we don't want 'Index', 'Index 2' as categories.
	END						as [SF_ParentId],

	dlang.Name				as [SF_CategoryName]
from departmentBase department
	JOIN departmentLang dlang on dlang.ObjID = department.ObjID
	JOIN departmentBase department2 on department2.ObjID = department.ParentID
where	dlang.Name != ''
and		department.ParentID != ''
and		dlang.LangName = 'nl'

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