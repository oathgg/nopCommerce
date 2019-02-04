﻿DELETE FROM [NOPCOMMERCE_BLANK]..[URLRecord] where EntityName = 'Product';
DELETE FROM [NOPCOMMERCE_BLANK]..[Product];

SET IDENTITY_INSERT [NOPCOMMERCE_BLANK]..[Product] ON;

with CTE_Product as 
(
	select 
		REPLACE(product.ObjId, 'p', '')				as [Id],
		5											as [ProductTypeId],
		0											as [ParentGroupedProductId],
		1											as [VisibleIndividually],
		productLang.Name							as [Name],
		productLang.Description						as [ShortDescription],
		productLang.LongDescription					as [FullDescription],
		null										as [AdminComment],
		1											as [ProductTemplateId],
		0											as [VendorId],
		0											as [ShowOnHomePage],
		LEFT(productLang.SearchEngKeywords, 400)	as [MetaKeywords],
		productLang.SearchEngDescription			as [MetaDescription],
		productLang.Name							as [MetaTitle],
		1											as [AllowCustomerReviews],
		0											as [ApprovedRatingSum],
		0											as [NotApprovedRatingSum],
		0											as [ApprovedTotalReviews],
		0											as [NotApprovedTotalReviews],
		0											as [SubjectToAcl],
		0											as [LimitedToStores],
		product.ItemNumber							as [Sku],
		null										as [ManufacturerPartNumber],
		null										as [Gtin],
		0											as [IsGiftCard],
		0											as [GiftCardTypeId],
		null										as [OverriddenGiftCardAmount],
		0											as [RequireOtherProducts],
		null										as [RequiredProductIds],
		0											as [AutomaticallyAddRequiredProducts],
		0											as [IsDownload],
		0											as [DownloadId],
		0											as [UnlimitedDownloads],
		0											as [MaxNumberOfDownloads],
		0											as [DownloadExpirationDays],
		0											as [DownloadActivationTypeId],
		0											as [HasSampleDownload],
		0											as [SampleDownloadId],
		0											as [HasUserAgreement],
		null										as [UserAgreementText],
		0											as [IsRecurring],
		100											as [RecurringCycleLength],
		0											as [RecurringCyclePeriodId],
		10											as [RecurringTotalCycles],
		0											as [IsRental],
		0											as [RentalPriceLength],
		0											as [RentalPricePeriodId],
		1											as [IsShipEnabled],
		0											as [IsFreeShipping],
		0											as [ShipSeparately],
		0											as [AdditionalShippingCharge],
		0											as [DeliveryDateId],
		0											as [IsTaxExempt],
		0											as [TaxCategoryId],
		0											as [IsTelecommunicationsOrBroadcastingOrElectronicServices],
		0											as [ManageInventoryMethodId],
		0											as [ProductAvailabilityRangeId],
		0											as [UseMultipleWarehouses],
		0											as [WarehouseId],
		0											as [StockQuantity],
		0											as [DisplayStockAvailability],
		0											as [DisplayStockQuantity],
		0											as [MinStockQuantity],
		0											as [LowStockActivityId],
		0											as [NotifyAdminForQuantityBelow],
		0											as [BackorderModeId],
		0											as [AllowBackInStockSubscriptions],
		0											as [OrderMinimumQuantity],
		1000										as [OrderMaximumQuantity],
		null										as [AllowedQuantities],
		0											as [AllowAddingOnlyExistingAttributeCombinations],
		0											as [NotReturnable],
		0											as [DisableBuyButton],
		0											as [DisableWishlistButton],
		0											as [AvailableForPreOrder],
		null										as [PreOrderAvailabilityStartDateTimeUtc],
		0											as [CallForPrice],
		product.Price								as [Price],
		0											as [OldPrice],
		0											as [ProductCost],
		0											as [CustomerEntersPrice],
		0											as [MinimumCustomerEnteredPrice],
		0											as [MaximumCustomerEnteredPrice],
		0											as [BasepriceEnabled],
		0											as [BasepriceAmount],
		0											as [BasepriceUnitId],
		0											as [BasepriceBaseAmount],
		0											as [BasepriceBaseUnitId],
		0											as [MarkAsNew],
		null										as [MarkAsNewStartDateTimeUtc],
		null										as [MarkAsNewEndDateTimeUtc],
		0											as [HasTierPrices],
		0											as [HasDiscountsApplied],
		product.Weight								as [Weight],
		product.Length								as [Length],
		product.Width								as [Width],
		product.Height								as [Height],
		null										as [AvailableStartDateTimeUtc],
		null										as [AvailableEndDateTimeUtc],
		0											as [DisplayOrder],
		product.Visible								as [Published],
		0											as [Deleted],
		GETDATE()									as [CreatedOnUtc],
		GETDATE()									as [UpdatedOnUtc],
		DupCount = row_number() over (PARTITION BY REPLACE(REPLACE(product.ObjId, 'p', ''), '-', '') ORDER BY REPLACE(REPLACE(product.ObjId, 'p', ''), '-', ''))
	from productBase product
		JOIN productLang productLang on productLang.ObjID = product.ObjID
		JOIN Links plink on plink.strTo = product.ObjID
		JOIN departmentBase category on category.ObjID = plink.strFrom
		JOIN departmentLang categoryLang on categoryLang.ObjID = category.ObjID
	where categoryLang.LangName = 'nl'
		and category.ParentID != ''
		and category.Creation != 0
) insert into  [NOPCOMMERCE_BLANK]..[Product]
	([Id], [ProductTypeId], [ParentGroupedProductId], [VisibleIndividually], [Name], [ShortDescription], [FullDescription], [AdminComment], [ProductTemplateId], [VendorId], [ShowOnHomePage], [MetaKeywords], [MetaDescription], [MetaTitle], [AllowCustomerReviews], [ApprovedRatingSum], [NotApprovedRatingSum], [ApprovedTotalReviews], [NotApprovedTotalReviews], [SubjectToAcl], [LimitedToStores], [Sku], [ManufacturerPartNumber], [Gtin], [IsGiftCard], [GiftCardTypeId], [OverriddenGiftCardAmount], [RequireOtherProducts], [RequiredProductIds], [AutomaticallyAddRequiredProducts], [IsDownload], [DownloadId], [UnlimitedDownloads], [MaxNumberOfDownloads], [DownloadExpirationDays], [DownloadActivationTypeId], [HasSampleDownload], [SampleDownloadId], [HasUserAgreement], [UserAgreementText], [IsRecurring], [RecurringCycleLength], [RecurringCyclePeriodId], [RecurringTotalCycles], [IsRental], [RentalPriceLength], [RentalPricePeriodId], [IsShipEnabled], [IsFreeShipping], [ShipSeparately], [AdditionalShippingCharge], [DeliveryDateId], [IsTaxExempt], [TaxCategoryId], [IsTelecommunicationsOrBroadcastingOrElectronicServices], [ManageInventoryMethodId], [ProductAvailabilityRangeId], [UseMultipleWarehouses], [WarehouseId], [StockQuantity], [DisplayStockAvailability], [DisplayStockQuantity], [MinStockQuantity], [LowStockActivityId], [NotifyAdminForQuantityBelow], [BackorderModeId], [AllowBackInStockSubscriptions], [OrderMinimumQuantity], [OrderMaximumQuantity], [AllowedQuantities], [AllowAddingOnlyExistingAttributeCombinations], [NotReturnable], [DisableBuyButton], [DisableWishlistButton], [AvailableForPreOrder], [PreOrderAvailabilityStartDateTimeUtc], [CallForPrice], [Price], [OldPrice], [ProductCost], [CustomerEntersPrice], [MinimumCustomerEnteredPrice], [MaximumCustomerEnteredPrice], [BasepriceEnabled], [BasepriceAmount], [BasepriceUnitId], [BasepriceBaseAmount], [BasepriceBaseUnitId], [MarkAsNew], [MarkAsNewStartDateTimeUtc], [MarkAsNewEndDateTimeUtc], [HasTierPrices], [HasDiscountsApplied], [Weight], [Length], [Width], [Height], [AvailableStartDateTimeUtc], [AvailableEndDateTimeUtc], [DisplayOrder], [Published], [Deleted], [CreatedOnUtc], [UpdatedOnUtc])
select
	[Id], [ProductTypeId], [ParentGroupedProductId], [VisibleIndividually], [Name], [ShortDescription], [FullDescription], [AdminComment], [ProductTemplateId], [VendorId], [ShowOnHomePage], [MetaKeywords], [MetaDescription], [MetaTitle], [AllowCustomerReviews], [ApprovedRatingSum], [NotApprovedRatingSum], [ApprovedTotalReviews], [NotApprovedTotalReviews], [SubjectToAcl], [LimitedToStores], [Sku], [ManufacturerPartNumber], [Gtin], [IsGiftCard], [GiftCardTypeId], [OverriddenGiftCardAmount], [RequireOtherProducts], [RequiredProductIds], [AutomaticallyAddRequiredProducts], [IsDownload], [DownloadId], [UnlimitedDownloads], [MaxNumberOfDownloads], [DownloadExpirationDays], [DownloadActivationTypeId], [HasSampleDownload], [SampleDownloadId], [HasUserAgreement], [UserAgreementText], [IsRecurring], [RecurringCycleLength], [RecurringCyclePeriodId], [RecurringTotalCycles], [IsRental], [RentalPriceLength], [RentalPricePeriodId], [IsShipEnabled], [IsFreeShipping], [ShipSeparately], [AdditionalShippingCharge], [DeliveryDateId], [IsTaxExempt], [TaxCategoryId], [IsTelecommunicationsOrBroadcastingOrElectronicServices], [ManageInventoryMethodId], [ProductAvailabilityRangeId], [UseMultipleWarehouses], [WarehouseId], [StockQuantity], [DisplayStockAvailability], [DisplayStockQuantity], [MinStockQuantity], [LowStockActivityId], [NotifyAdminForQuantityBelow], [BackorderModeId], [AllowBackInStockSubscriptions], [OrderMinimumQuantity], [OrderMaximumQuantity], [AllowedQuantities], [AllowAddingOnlyExistingAttributeCombinations], [NotReturnable], [DisableBuyButton], [DisableWishlistButton], [AvailableForPreOrder], [PreOrderAvailabilityStartDateTimeUtc], [CallForPrice], [Price], [OldPrice], [ProductCost], [CustomerEntersPrice], [MinimumCustomerEnteredPrice], [MaximumCustomerEnteredPrice], [BasepriceEnabled], [BasepriceAmount], [BasepriceUnitId], [BasepriceBaseAmount], [BasepriceBaseUnitId], [MarkAsNew], [MarkAsNewStartDateTimeUtc], [MarkAsNewEndDateTimeUtc], [HasTierPrices], [HasDiscountsApplied], [Weight], [Length], [Width], [Height], [AvailableStartDateTimeUtc], [AvailableEndDateTimeUtc], [DisplayOrder], [Published], [Deleted], [CreatedOnUtc], [UpdatedOnUtc]
from CTE_Product
	where DupCount = 1;

SET IDENTITY_INSERT [NOPCOMMERCE_BLANK]..[Product] OFF;

insert into [NOPCOMMERCE_BLANK]..[URLRecord]
(EntityId, EntityName, Slug, IsActive, LanguageId)
select 
	[Product].Id, 'Product', 
	-- Replaces any weird characters in the slug as this will be used for the URL.
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RTRIM([Product].NAME)
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
from [NOPCOMMERCE_BLANK]..[Product]
	LEFT JOIN [NOPCOMMERCE_BLANK]..[URLRecord] on [URLRecord].EntityId = [Product].Id
		AND [URLRecord].EntityName = 'Product'
where	[URLRecord].EntityId IS NULL
AND		[Product].Published = 1;