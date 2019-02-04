﻿/*	Automated migration script to migrate all data from ShopFactory to NopCommerce

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
	
	*************************************************************************
		INSERT THROUGH POWERSHELL AS THESE FILES ARE LOCATED ON THE DRIVE
		WE WILL ALSO HAVE TO UPDATE THE [PICTUREBINARY] TABLE.
	*************************************************************************

	- [Picture]
		-- FROM SF
		-> [SeoFilename]
		-> [AltAttribute]
		-> [TitleAttribute]
		-> [MimeType] : 'image/jpeg'

		-- DEFAULT
		-> [Id] Not null, Incremental 1,1
		-> [IsNew], 0

	- [PictureBinary]
		-- FROM PS
		-> [PictureId], -> Take the [Id] from the [Picture] table.
		-> [BinaryData], Convert image to binary file with Powershell.

		-- DEFAULT
		-> [Id] Not null, Incremental 1,1


	*************************************************************************
		BASE TABLES
	*************************************************************************

	- [Category]
		-- FROM SF
		-> [Name]
		-> [ParentCategoryId] Not null, if main category then 0.
		-> [IncludeInTopMenu], if main category then 1
		-> [ShowOnHomePage], 0
		-> [Description]
		-> [MetaTitle]
		-> [MetaKeywords]
		-> [MetaDescription]
		-> [Published], Visible

		-- DEFAULT
		-> [Id] Not null, Incremental 1,1
		-> [PictureId] Not null, 
		-> [CategoryTemplateId], 1
		-> [PageSize] Not null, 6
		-> [AllowCustomersToSelectPageSize], 1
		-> [SubjectToAcl], 0
		-> [LimitedToStores], 0
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
		-> [Id] Not null, Incremental 1,1


	*************************************************************************
		DEPENDANCY TABLES
	*************************************************************************

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