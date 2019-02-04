Delete from [NOPCOMMERCE_BLANK]..Product_Category_Mapping;

with CTE_Product_Category_Mapping AS 
(
	select 
		REPLACE(product.ObjID, 'p', '')						[ProductId],
		REPLACE(REPLACE(category.ObjId, 'D', ''), '-', '')	[CategoryId],
		0													[IsFeaturedProduct],
		0													[DisplayOrder]
	from [SF]..productBase product
			JOIN [SF]..productLang productLang on productLang.ObjID = product.ObjID
			JOIN [SF]..Links relation on relation.strTo = product.ObjID
			JOIN [SF]..departmentBase category on category.ObjID = relation.strFrom
			JOIN [NOPCOMMERCE_BLANK]..Category c on c.Id = REPLACE(REPLACE(category.ObjId, 'D', ''), '-', '')
		where category.ParentID != ''
			and category.Creation != 0
) 
INSERT INTO [NOPCOMMERCE_BLANK]..[Product_Category_Mapping] 
	(ProductId, CategoryId, IsFeaturedProduct, DisplayOrder)
SELECT 
	ProductId, CategoryId, IsFeaturedProduct, DisplayOrder
FROM CTE_Product_Category_Mapping