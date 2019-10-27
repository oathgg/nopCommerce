/*
	RUN IN THE FOLLOWING ORDER

	-> SF_Manufacturer.sql
	-> SF_Category.sql
	-> SF_Product.sql
	-> SF_Product_Category_Mapping.sql
	-> SF_Post_SlugFix.sql
	-> SF_Post_Beautify.sql

	POST PowerShell script
	-> Fix-UrlReferences.ps1
    
    /* 
        Update the $RootContentFolder variable before running the next scripts, set the variable to downloaded language folder inside the contents folder.
        When you download the folders make sure you leave the hierarchy intact.
            contents
                nl      <---- $RootContentFolder
                media   <---- $RootMediaFolder
    */
    -> Fix-ImageLinks.ps1
    -> Import-SFImages.ps1
*/



/*	Migration script to migrate all data from ShopFactory to NopCommerce

	- Payments through iDeal ??
	- Categories
		- Name
		- Description
		- Meta
		- Picture
		- Sub categories
	- Products
		- Name
		- Short description
		- Full description
		- Picture
		- Price
	- Manufacturer
		- Name
		- Description
		- Meta
		- Picture
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

	- [Manufacturer]
		-- FROM SF
		-> [Id], ObjId (REPLACE, 'BR', '')
		-> [Name], Name
		-> [Published], Enabled

		-- DEFAULT
		-> [Description], ''
		-> [ManufacturerTemplateId], 1
		-> [PictureId], 0
		-> [PageSize], 6
		-> [AllowCustomersToSelectPageSize], 1
		-> [SubjectToAcl], 0
		-> [LimitedToStores], 0
		-> [Deleted], 0
		-> [DisplayOrder], ROW_NUMBER() OVER [MANUFACTURER]
		-> [CreatedOnUtc], GETDATE()
		-> [UpdatedOnUtc], GETDATE()

	- [Category]
		-- FROM SF
		-> [Id], ObjId (REPLACE, 'D', '') & (REPLACE, '-', '')
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