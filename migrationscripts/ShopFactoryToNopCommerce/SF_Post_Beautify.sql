-- Show the default categories on the home page.
update [NOPCOMMERCE_BLANK]..Category
	SET ShowOnHomePage = 1
where	ParentCategoryId = 0
AND		Published = 1

-- Remove all SKU names from product name, if the Name is not the same as the SKU.
update [NOPCOMMERCE_BLANK]..Product
	SET Name = Replace(Name, Sku, '')
where Name != Sku
