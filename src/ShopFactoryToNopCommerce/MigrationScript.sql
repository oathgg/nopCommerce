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
	
	/* 
		BASE TABLES
	*/
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